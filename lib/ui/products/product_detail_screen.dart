import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../widgets/product_add_to_cart_button.dart';
import '../../widgets/product_color_selector.dart';
import '../../widgets/product_quantity_selector.dart';
import '../../widgets/product_size_selector.dart';
import '../cart/cart_manager.dart';
import '../cart/cart_screen.dart';
import 'products_overview_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen(
    this.product, {
    super.key,
  });

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;
  int _quantity = 1;
  String? _selectedColor;
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product.isFavorite;
    _selectedColor = widget.product.availableColors.isNotEmpty
        ? widget.product.availableColors.first
        : null;
    _selectedSize = widget.product.availableSizes.isNotEmpty
        ? widget.product.availableSizes.first
        : null;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _updateQuantity(int delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(1, 20);
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  PageRouteBuilder _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  void _navigateHome() {
    Navigator.of(context).pushAndRemoveUntil(
      _buildPageRoute(const ProductsOverviewScreen()),
      (route) => false,
    );
  }

  void _navigateCart() {
    Navigator.of(context).push(
      _buildPageRoute(const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _navigateHome,
            tooltip: 'Trang chủ',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _navigateCart,
            tooltip: 'Giỏ hàng',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 320,
              width: double.infinity,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Mã sản phẩm: ${product.id ?? 'N/A'}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        product.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tùy chọn mua hàng',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite
                              ? Colors.redAccent
                              : theme.iconTheme.color,
                        ),
                        onPressed: _toggleFavorite,
                        tooltip: _isFavorite
                            ? 'Bỏ yêu thích'
                            : 'Thêm yêu thích',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isFavorite
                        ? 'Sản phẩm đã được thêm vào danh sách yêu thích.'
                        : 'Nhấn trái tim để thêm vào danh sách yêu thích.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Chọn màu sắc'),
                  ProductColorSelector(
                    availableColors: product.availableColors,
                    selectedColor: _selectedColor,
                    onColorSelected: (value) {
                      setState(() {
                        _selectedColor = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Chọn kích thước'),
                  ProductSizeSelector(
                    availableSizes: product.availableSizes,
                    selectedSize: _selectedSize,
                    onSizeSelected: (value) {
                      setState(() {
                        _selectedSize = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Số lượng'),
                  ProductQuantitySelector(
                    quantity: _quantity,
                    selectedSummary:
                        'Màu: ${_selectedColor ?? '-'} • Size: ${_selectedSize ?? '-'}',
                    onDecrement: () => _updateQuantity(-1),
                    onIncrement: () => _updateQuantity(1),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: theme.colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Tóm tắt đơn hàng',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              Chip(label: Text('Số lượng: $_quantity')),
                              Chip(
                                label: Text('Màu: ${_selectedColor ?? '-'}'),
                              ),
                              Chip(
                                label: Text('Size: ${_selectedSize ?? '-'}'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? Colors.redAccent : null,
                          ),
                          label: Text(
                            _isFavorite ? 'Yêu thích' : 'Thêm vào yêu thích',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ProductAddToCartButton(
                          onPressed: () {
                            final cart = context.read<CartManager>();
                            cart.addItem(product, quantity: _quantity);

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã thêm $_quantity sản phẩm vào giỏ hàng.',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
