-- ============================================
-- Yarpay POS — Initial Database Schema
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. RESTAURANTS
create table if not exists restaurants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text default '',
  phone text default '',
  logo_url text default '',
  created_at timestamptz not null default now()
);

-- 2. USER PROFILES (extends auth.users)
create table if not exists user_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  full_name text not null default '',
  role text not null default 'cashier' check (role in ('owner', 'manager', 'cashier')),
  created_at timestamptz not null default now(),
  unique(user_id)
);

-- 3. CATEGORIES
create table if not exists categories (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  name text not null,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- 4. PRODUCTS
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  category_id uuid not null references categories(id) on delete cascade,
  name text not null,
  price double precision not null default 0,
  image text not null default '🍽️',
  available boolean not null default true,
  created_at timestamptz not null default now()
);

-- 5. ORDERS
create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  customer_name text default '',
  table_number text default '',
  payment_method text not null default 'Cash',
  subtotal double precision not null default 0,
  tax double precision not null default 0,
  total double precision not null default 0,
  created_at timestamptz not null default now()
);

-- 6. ORDER ITEMS
create table if not exists order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  product_id uuid not null references products(id) on delete cascade,
  product_name text not null,
  price double precision not null default 0,
  quantity int not null default 1,
  created_at timestamptz not null default now()
);

-- ============================================
-- INDEXES
-- ============================================
create index if not exists idx_user_profiles_user_id on user_profiles(user_id);
create index if not exists idx_user_profiles_restaurant_id on user_profiles(restaurant_id);
create index if not exists idx_categories_restaurant_id on categories(restaurant_id);
create index if not exists idx_products_restaurant_id on products(restaurant_id);
create index if not exists idx_products_category_id on products(category_id);
create index if not exists idx_orders_restaurant_id on orders(restaurant_id);
create index if not exists idx_orders_created_at on orders(created_at desc);
create index if not exists idx_order_items_order_id on order_items(order_id);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

alter table restaurants enable row level security;
alter table user_profiles enable row level security;
alter table categories enable row level security;
alter table products enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;

-- Helper function: get current user's restaurant_id
create or replace function get_user_restaurant_id()
returns uuid as $$
  select restaurant_id from user_profiles where user_id = auth.uid() limit 1;
$$ language sql security definer stable;

-- Alias used by later migrations
create or replace function get_my_restaurant_id()
returns uuid as $$
  select restaurant_id from user_profiles where user_id = auth.uid() limit 1;
$$ language sql security definer stable;

-- RESTAURANTS: users can only read their own restaurant
create policy "Users can view own restaurant"
  on restaurants for select
  using (id = get_user_restaurant_id());

-- Owners can update their restaurant
create policy "Owners can update restaurant"
  on restaurants for update
  using (
    id = get_user_restaurant_id()
    and exists (
      select 1 from user_profiles
      where user_id = auth.uid() and role = 'owner'
    )
  );

-- USER PROFILES: users can read profiles in their restaurant
create policy "Users can view restaurant profiles"
  on user_profiles for select
  using (restaurant_id = get_user_restaurant_id());

-- Users can update their own profile
create policy "Users can update own profile"
  on user_profiles for update
  using (user_id = auth.uid());

-- Owners can insert new users into their restaurant
create policy "Owners can insert users"
  on user_profiles for insert
  with check (
    restaurant_id = get_user_restaurant_id()
    and exists (
      select 1 from user_profiles
      where user_id = auth.uid() and role = 'owner'
    )
  );

-- CATEGORIES: full CRUD within restaurant
create policy "Users can view restaurant categories"
  on categories for select
  using (restaurant_id = get_user_restaurant_id());

create policy "Managers can insert categories"
  on categories for insert
  with check (
    restaurant_id = get_user_restaurant_id()
    and exists (
      select 1 from user_profiles
      where user_id = auth.uid() and role in ('owner', 'manager')
    )
  );

create policy "Managers can update categories"
  on categories for update
  using (
    restaurant_id = get_user_restaurant_id()
    and exists (
      select 1 from user_profiles
      where user_id = auth.uid() and role in ('owner', 'manager')
    )
  );

create policy "Managers can delete categories"
  on categories for delete
  using (
    restaurant_id = get_user_restaurant_id()
    and exists (
      select 1 from user_profiles
      where user_id = auth.uid() and role in ('owner', 'manager')
    )
  );

-- PRODUCTS: full CRUD within restaurant
create policy "Users can view restaurant products"
  on products for select
  using (restaurant_id = get_user_restaurant_id());

create policy "Managers can insert products"
  on products for insert
  with check (
    restaurant_id = get_user_restaurant_id()
    and exists (
      select 1 from user_profiles
      where user_id = auth.uid() and role in ('owner', 'manager')
    )
  );

create policy "Managers can update products"
  on products for update
  using (
    restaurant_id = get_user_restaurant_id()
    and exists (
      select 1 from user_profiles
      where user_id = auth.uid() and role in ('owner', 'manager')
    )
  );

create policy "Managers can delete products"
  on products for delete
  using (
    restaurant_id = get_user_restaurant_id()
    and exists (
      select 1 from user_profiles
      where user_id = auth.uid() and role in ('owner', 'manager')
    )
  );

-- ORDERS: all authenticated users can read, cashiers can insert
create policy "Users can view restaurant orders"
  on orders for select
  using (restaurant_id = get_user_restaurant_id());

create policy "Cashiers can insert orders"
  on orders for insert
  with check (restaurant_id = get_user_restaurant_id());

-- ORDER ITEMS: read with parent order, insert with parent order
create policy "Users can view order items"
  on order_items for select
  using (
    order_id in (
      select id from orders
      where restaurant_id = get_user_restaurant_id()
    )
  );

create policy "Cashiers can insert order items"
  on order_items for insert
  with check (
    order_id in (
      select id from orders
      where restaurant_id = get_user_restaurant_id()
    )
  );
