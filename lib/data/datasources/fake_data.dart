import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
// import '../models/category.dart';
// import '../models/product.dart';


const categories = [
  Category(id: 'all', name: 'All'),
  Category(id: 'pizza', name: 'Pizza'),
  Category(id: 'burger', name: 'Burger'),
  Category(id: 'drinks', name: 'Drinks'),
];

const products = [
  Product(
    id: '1',
    name: 'Margherita',
    categoryId: 'pizza',
    price: 299,
    image: '🍕',
  ),
  Product(
    id: '2',
    name: 'Pepperoni',
    categoryId: 'pizza',
    price: 399,
    image: '🍕',
  ),
  Product(
    id: '3',
    name: 'Chicken Burger',
    categoryId: 'burger',
    price: 249,
    image: '🍔',
  ),
  Product(
    id: '4',
    name: 'Veg Burger',
    categoryId: 'burger',
    price: 199,
    image: '🍔',
  ),
  Product(
    id: '5',
    name: 'Coke',
    categoryId: 'drinks',
    price: 60,
    image: '🥤',
  ),
  Product(
    id: '6',
    name: 'Pepsi',
    categoryId: 'drinks',
    price: 60,
    image: '🥤',
  ),
];