-- ============================================
-- MIGRATION: Add discount, status, customers
-- ============================================

-- 1. Add new columns to orders table
ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount double precision DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount_type text DEFAULT 'none';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS status text DEFAULT 'completed';

-- 2. Create customers table
CREATE TABLE IF NOT EXISTS customers (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  restaurant_id uuid NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
  name text NOT NULL,
  phone text DEFAULT '',
  email text DEFAULT '',
  address text DEFAULT '',
  notes text DEFAULT '',
  total_orders int DEFAULT 0,
  total_spent double precision DEFAULT 0,
  last_order_at timestamptz,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own restaurant customers"
  ON customers FOR ALL
  USING (restaurant_id = get_my_restaurant_id());

-- 3. Add customer_id to orders
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_id uuid REFERENCES customers(id) ON DELETE SET NULL;

-- 4. Update create_order RPC
CREATE OR REPLACE FUNCTION create_order(
  p_customer_name text,
  p_table_number text,
  p_payment_method text,
  p_subtotal double precision,
  p_discount double precision DEFAULT 0,
  p_discount_type text DEFAULT 'none',
  p_tax double precision,
  p_total double precision,
  p_items json,
  p_customer_id uuid DEFAULT NULL
)
RETURNS json AS $$
DECLARE
  v_rid uuid;
  v_order json;
  v_order_id uuid;
  v_item json;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RAISE EXCEPTION 'No restaurant found'; END IF;

  INSERT INTO orders (restaurant_id, customer_name, customer_id, table_number, payment_method, subtotal, discount, discount_type, tax, total)
  VALUES (v_rid, p_customer_name, p_customer_id, p_table_number, p_payment_method, p_subtotal, p_discount, p_discount_type, p_tax, p_total)
  RETURNING row_to_json(orders.*) INTO v_order;

  v_order_id := (v_order->>'id')::uuid;

  FOR v_item IN SELECT * FROM json_array_elements(p_items)
  LOOP
    INSERT INTO order_items (order_id, product_id, product_name, price, quantity)
    VALUES (
      v_order_id,
      (v_item->>'product_id')::uuid,
      v_item->>'product_name',
      (v_item->>'price')::double precision,
      (v_item->>'quantity')::int
    );
  END LOOP;

  RETURN v_order;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Update get_orders to include new fields
CREATE OR REPLACE FUNCTION get_orders()
RETURNS json AS $$
DECLARE
  v_rid uuid;
  v_orders json;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RETURN '[]'::json; END IF;

  SELECT coalesce(json_agg(row_to_json(o.*)), '[]'::json) INTO v_orders
  FROM (
    SELECT ord.*, coalesce((
      SELECT json_agg(row_to_json(oi.*))
      FROM order_items oi WHERE oi.order_id = ord.id
    ), '[]'::json) AS items
    FROM orders ord
    WHERE ord.restaurant_id = v_rid
    ORDER BY ord.created_at DESC
  ) o;

  RETURN v_orders;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Add customer RPCs
CREATE OR REPLACE FUNCTION get_customers()
RETURNS json AS $$
DECLARE
  v_rid uuid;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RETURN '[]'::json; END IF;
  RETURN (SELECT coalesce(json_agg(row_to_json(c.*)), '[]'::json)
    FROM (SELECT * FROM customers WHERE restaurant_id = v_rid ORDER BY name) c);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION add_customer(
  p_name text,
  p_phone text DEFAULT '',
  p_email text DEFAULT '',
  p_address text DEFAULT ''
)
RETURNS json AS $$
DECLARE
  v_rid uuid;
  v_result json;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RAISE EXCEPTION 'No restaurant found'; END IF;
  INSERT INTO customers (restaurant_id, name, phone, email, address)
  VALUES (v_rid, p_name, p_phone, p_email, p_address)
  RETURNING row_to_json(customers.*) INTO v_result;
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION update_customer(
  p_id uuid,
  p_name text,
  p_phone text DEFAULT '',
  p_email text DEFAULT '',
  p_address text DEFAULT ''
)
RETURNS json AS $$
DECLARE
  v_result json;
BEGIN
  UPDATE customers SET name = p_name, phone = p_phone, email = p_email, address = p_address
  WHERE id = p_id AND restaurant_id = get_my_restaurant_id()
  RETURNING row_to_json(customers.*) INTO v_result;
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION delete_customer(p_id uuid)
RETURNS void AS $$
BEGIN
  DELETE FROM customers WHERE id = p_id AND restaurant_id = get_my_restaurant_id();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Update order status
CREATE OR REPLACE FUNCTION update_order_status(p_id uuid, p_status text)
RETURNS void AS $$
BEGIN
  UPDATE orders SET status = p_status
  WHERE id = p_id AND restaurant_id = get_my_restaurant_id();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Void/refund order
CREATE OR REPLACE FUNCTION void_order(p_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE orders SET status = 'voided'
  WHERE id = p_id AND restaurant_id = get_my_restaurant_id();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Get analytics data
CREATE OR REPLACE FUNCTION get_analytics()
RETURNS json AS $$
DECLARE
  v_rid uuid;
  v_today_start timestamptz;
  v_month_start timestamptz;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RETURN '{}'::json; END IF;

  v_today_start := date_trunc('day', now());
  v_month_start := date_trunc('month', now());

  RETURN json_build_object(
    'today_sales', COALESCE((SELECT sum(total) FROM orders
      WHERE restaurant_id = v_rid AND created_at >= v_today_start AND status != 'voided'), 0),
    'today_orders', COALESCE((SELECT count(*) FROM orders
      WHERE restaurant_id = v_rid AND created_at >= v_today_start AND status != 'voided'), 0),
    'month_sales', COALESCE((SELECT sum(total) FROM orders
      WHERE restaurant_id = v_rid AND created_at >= v_month_start AND status != 'voided'), 0),
    'month_orders', COALESCE((SELECT count(*) FROM orders
      WHERE restaurant_id = v_rid AND created_at >= v_month_start AND status != 'voided'), 0),
    'total_sales', COALESCE((SELECT sum(total) FROM orders
      WHERE restaurant_id = v_rid AND status != 'voided'), 0),
    'total_orders', COALESCE((SELECT count(*) FROM orders
      WHERE restaurant_id = v_rid AND status != 'voided'), 0),
    'best_sellers', COALESCE((SELECT json_agg(row_to_json(bs.*)) FROM (
      SELECT oi.product_name, sum(oi.quantity) as total_qty, sum(oi.price * oi.quantity) as total_revenue
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      WHERE o.restaurant_id = v_rid AND o.status != 'voided'
      GROUP BY oi.product_name
      ORDER BY total_qty DESC
      LIMIT 10
    ) bs), '[]'::json),
    'payment_breakdown', COALESCE((SELECT json_agg(row_to_json(pb.*)) FROM (
      SELECT payment_method, count(*) as order_count, sum(total) as total_amount
      FROM orders
      WHERE restaurant_id = v_rid AND status != 'voided'
      GROUP BY payment_method
    ) pb), '[]'::json)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Grant all new permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON customers TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

GRANT EXECUTE ON FUNCTION create_order(text, text, text, double precision, double precision, text, double precision, double precision, json, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_customers() TO authenticated;
GRANT EXECUTE ON FUNCTION add_customer(text, text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION update_customer(uuid, text, text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_customer(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION update_order_status(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION void_order(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_analytics() TO authenticated;
