-- ============================================
-- COMPREHENSIVE ANALYTICS RPCs
-- ============================================

-- 1. DAILY SALES (last 30 days)
CREATE OR REPLACE FUNCTION get_daily_sales(p_days int DEFAULT 30)
RETURNS json AS $$
DECLARE
  v_rid uuid;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RETURN '[]'::json; END IF;
  RETURN (SELECT coalesce(json_agg(row_to_json(d.*)), '[]'::json) FROM (
    SELECT
      date_trunc('day', created_at)::date AS date,
      count(*) AS order_count,
      coalesce(sum(total), 0) AS revenue,
      coalesce(sum(subtotal), 0) AS gross_revenue,
      coalesce(sum(discount), 0) AS discount_total,
      coalesce(sum(tax), 0) AS tax_total,
      CASE WHEN count(*) > 0 THEN coalesce(sum(total), 0) / count(*) ELSE 0 END AS avg_order_value
    FROM orders
    WHERE restaurant_id = v_rid
      AND created_at >= now() - (p_days || ' days')::interval
      AND status != 'voided'
    GROUP BY date_trunc('day', created_at)::date
    ORDER BY date
  ) d);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. HOURLY HEATMAP (orders by hour of day, 0-23)
CREATE OR REPLACE FUNCTION get_hourly_heatmap()
RETURNS json AS $$
DECLARE
  v_rid uuid;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RETURN '[]'::json; END IF;
  RETURN (SELECT coalesce(json_agg(row_to_json(h.*)), '[]'::json) FROM (
    SELECT
      EXTRACT(HOUR FROM created_at)::int AS hour,
      count(*) AS order_count,
      coalesce(sum(total), 0) AS revenue
    FROM orders
    WHERE restaurant_id = v_rid AND status != 'voided'
    GROUP BY EXTRACT(HOUR FROM created_at)
    ORDER BY hour
  ) h);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. DAY OF WEEK BREAKDOWN
CREATE OR REPLACE FUNCTION get_day_of_week_sales()
RETURNS json AS $$
DECLARE
  v_rid uuid;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RETURN '[]'::json; END IF;
  RETURN (SELECT coalesce(json_agg(row_to_json(d.*)), '[]'::json) FROM (
    SELECT
      CASE EXTRACT(DOW FROM created_at)
        WHEN 0 THEN 'Sunday' WHEN 1 THEN 'Monday' WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday' WHEN 4 THEN 'Thursday' WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
      END AS day_name,
      EXTRACT(DOW FROM created_at)::int AS day_num,
      count(*) AS order_count,
      coalesce(sum(total), 0) AS revenue
    FROM orders
    WHERE restaurant_id = v_rid AND status != 'voided'
    GROUP BY EXTRACT(DOW FROM created_at)
    ORDER BY day_num
  ) d);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. CATEGORY BREAKDOWN
CREATE OR REPLACE FUNCTION get_category_sales()
RETURNS json AS $$
DECLARE
  v_rid uuid;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RETURN '[]'::json; END IF;
  RETURN (SELECT coalesce(json_agg(row_to_json(c.*)), '[]'::json) FROM (
    SELECT
      COALESCE(cat.name, 'Uncategorized') AS category_name,
      count(DISTINCT o.id) AS order_count,
      sum(oi.quantity) AS items_sold,
      sum(oi.price * oi.quantity) AS revenue
    FROM order_items oi
    JOIN orders o ON o.id = oi.order_id
    JOIN products p ON p.id = oi.product_id
    LEFT JOIN categories cat ON cat.id = p.category_id
    WHERE o.restaurant_id = v_rid AND o.status != 'voided'
    GROUP BY cat.name
    ORDER BY revenue DESC
  ) c);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. TOP PRODUCTS (best & worst sellers)
CREATE OR REPLACE FUNCTION get_product_sales(p_limit int DEFAULT 20)
RETURNS json AS $$
DECLARE
  v_rid uuid;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RETURN '[]'::json; END IF;
  RETURN (SELECT coalesce(json_agg(row_to_json(p.*)), '[]'::json) FROM (
    SELECT
      oi.product_name,
      COALESCE(cat.name, 'Uncategorized') AS category,
      sum(oi.quantity) AS total_qty,
      sum(oi.price * oi.quantity) AS total_revenue,
      avg(oi.price) AS avg_price,
      count(DISTINCT o.id) AS appeared_in_orders
    FROM order_items oi
    JOIN orders o ON o.id = oi.order_id
    LEFT JOIN products p ON p.id = oi.product_id
    LEFT JOIN categories cat ON cat.id = p.category_id
    WHERE o.restaurant_id = v_rid AND o.status != 'voided'
    GROUP BY oi.product_name, cat.name
    ORDER BY total_qty DESC
    LIMIT p_limit
  ) p);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. PAYMENT ANALYTICS
CREATE OR REPLACE FUNCTION get_payment_analytics()
RETURNS json AS $$
DECLARE
  v_rid uuid;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RETURN '{}'::json; END IF;
  RETURN json_build_object(
    'breakdown', (SELECT coalesce(json_agg(row_to_json(pb.*)), '[]'::json) FROM (
      SELECT
        payment_method,
        count(*) AS order_count,
        coalesce(sum(total), 0) AS total_amount,
        CASE WHEN count(*) > 0 THEN coalesce(sum(total), 0) / count(*) ELSE 0 END AS avg_amount,
        round(count(*)::numeric / (SELECT count(*) FROM orders WHERE restaurant_id = v_rid AND status != 'voided') * 100, 1) AS percentage
      FROM orders
      WHERE restaurant_id = v_rid AND status != 'voided'
      GROUP BY payment_method
      ORDER BY total_amount DESC
    ) pb),
    'daily_trend', (SELECT coalesce(json_agg(row_to_json(dt.*)), '[]'::json) FROM (
      SELECT
        date_trunc('day', created_at)::date AS date,
        payment_method,
        count(*) AS order_count,
        coalesce(sum(total), 0) AS amount
      FROM orders
      WHERE restaurant_id = v_rid AND status != 'voided'
        AND created_at >= now() - interval '30 days'
      GROUP BY date_trunc('day', created_at)::date, payment_method
      ORDER BY date
    ) dt)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. CUSTOMER ANALYTICS
CREATE OR REPLACE FUNCTION get_customer_analytics()
RETURNS json AS $$
DECLARE
  v_rid uuid;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RETURN '{}'::json; END IF;
  RETURN json_build_object(
    'total_customers', (SELECT count(*) FROM customers WHERE restaurant_id = v_rid),
    'repeat_customers', (SELECT count(*) FROM customers WHERE restaurant_id = v_rid AND total_orders > 1),
    'avg_orders_per_customer', (SELECT CASE WHEN count(*) > 0 THEN round(avg(total_orders)::numeric, 1) ELSE 0 END FROM customers WHERE restaurant_id = v_rid),
    'avg_spend_per_customer', (SELECT CASE WHEN count(*) > 0 THEN round(avg(total_spent)::numeric, 0) ELSE 0 END FROM customers WHERE restaurant_id = v_rid),
    'top_customers', (SELECT coalesce(json_agg(row_to_json(tc.*)), '[]'::json) FROM (
      SELECT name, phone, total_orders, total_spent, last_order_at
      FROM customers
      WHERE restaurant_id = v_rid
      ORDER BY total_spent DESC
      LIMIT 10
    ) tc),
    'new_vs_returning', (SELECT coalesce(json_agg(row_to_json(nr.*)), '[]'::json) FROM (
      SELECT
        CASE WHEN c.total_orders = 1 THEN 'New' ELSE 'Returning' END AS type,
        count(DISTINCT o.id) AS order_count,
        coalesce(sum(o.total), 0) AS revenue
      FROM orders o
      LEFT JOIN customers c ON c.id = o.customer_id
      WHERE o.restaurant_id = v_rid AND o.status != 'voided'
      GROUP BY CASE WHEN c.total_orders = 1 THEN 'New' ELSE 'Returning' END
    ) nr)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. MONTHLY COMPARISON
CREATE OR REPLACE FUNCTION get_monthly_comparison()
RETURNS json AS $$
DECLARE
  v_rid uuid;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RETURN '{}'::json; END IF;
  RETURN json_build_object(
    'this_month', (SELECT row_to_json(m.*) FROM (
      SELECT
        coalesce(sum(total), 0) AS revenue,
        count(*) AS orders,
        CASE WHEN count(*) > 0 THEN coalesce(sum(total), 0) / count(*) ELSE 0 END AS avg_order_value,
        coalesce(sum(discount), 0) AS total_discount
      FROM orders
      WHERE restaurant_id = v_rid
        AND created_at >= date_trunc('month', now())
        AND status != 'voided'
    ) m),
    'last_month', (SELECT row_to_json(m.*) FROM (
      SELECT
        coalesce(sum(total), 0) AS revenue,
        count(*) AS orders,
        CASE WHEN count(*) > 0 THEN coalesce(sum(total), 0) / count(*) ELSE 0 END AS avg_order_value,
        coalesce(sum(discount), 0) AS total_discount
      FROM orders
      WHERE restaurant_id = v_rid
        AND created_at >= date_trunc('month', now() - interval '1 month')
        AND created_at < date_trunc('month', now())
        AND status != 'voided'
    ) m)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. DISCOUNT IMPACT
CREATE OR REPLACE FUNCTION get_discount_analytics()
RETURNS json AS $$
DECLARE
  v_rid uuid;
BEGIN
  v_rid := get_my_restaurant_id();
  IF v_rid IS NULL THEN RETURN '{}'::json; END IF;
  RETURN json_build_object(
    'total_orders_with_discount', (SELECT count(*) FROM orders WHERE restaurant_id = v_rid AND discount > 0 AND status != 'voided'),
    'total_discount_given', (SELECT coalesce(sum(discount), 0) FROM orders WHERE restaurant_id = v_rid AND status != 'voided'),
    'avg_discount', (SELECT CASE WHEN count(*) > 0 THEN coalesce(avg(discount), 0) ELSE 0 END FROM orders WHERE restaurant_id = v_rid AND discount > 0 AND status != 'voided'),
    'discount_by_type', (SELECT coalesce(json_agg(row_to_json(dt.*)), '[]'::json) FROM (
      SELECT
        discount_type,
        count(*) AS order_count,
        coalesce(sum(discount), 0) AS total_amount
      FROM orders
      WHERE restaurant_id = v_rid AND discount > 0 AND status != 'voided'
      GROUP BY discount_type
    ) dt)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GRANT ALL
GRANT EXECUTE ON FUNCTION get_daily_sales(int) TO authenticated;
GRANT EXECUTE ON FUNCTION get_hourly_heatmap() TO authenticated;
GRANT EXECUTE ON FUNCTION get_day_of_week_sales() TO authenticated;
GRANT EXECUTE ON FUNCTION get_category_sales() TO authenticated;
GRANT EXECUTE ON FUNCTION get_product_sales(int) TO authenticated;
GRANT EXECUTE ON FUNCTION get_payment_analytics() TO authenticated;
GRANT EXECUTE ON FUNCTION get_customer_analytics() TO authenticated;
GRANT EXECUTE ON FUNCTION get_monthly_comparison() TO authenticated;
GRANT EXECUTE ON FUNCTION get_discount_analytics() TO authenticated;
