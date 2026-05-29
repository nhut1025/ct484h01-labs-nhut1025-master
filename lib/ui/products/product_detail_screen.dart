import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../widgets/product_add_to_cart_button.dart';
import '../../widgets/product_color_selector.dart';
import '../../widgets/product_quantity_selector.dart';
import '../../widgets/product_size_selector.dart';

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

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : null,
            ),
            onPressed: _toggleFavorite,
            tooltip: _isFavorite ? 'Bỏ yêu thích' : 'Thêm yêu thích',
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                product.description,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            _buildSectionTitle('Chọn màu sắc'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ProductColorSelector(
                availableColors: product.availableColors,
                selectedColor: _selectedColor,
                onColorSelected: (value) {
                  setState(() {
                    _selectedColor = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Chọn kích thước'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ProductSizeSelector(
                availableSizes: product.availableSizes,
                selectedSize: _selectedSize,
                onSizeSelected: (value) {
                  setState(() {
                    _selectedSize = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Số lượng'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ProductQuantitySelector(
                quantity: _quantity,
                selectedSummary: 'Màu: ${_selectedColor ?? '-'} • Size: ${_selectedSize ?? '-'}',
                onDecrement: () => _updateQuantity(-1),
                onIncrement: () => _updateQuantity(1),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ProductAddToCartButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã thêm sản phẩm vào giỏ hàng (chỉ demo giao diện).'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
