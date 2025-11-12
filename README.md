# RoastMaster ID - Coffee Equipment E-commerce App

A comprehensive e-commerce mobile application for coffee roasting equipment built with Flutter and GetX for state management.

## Project Structure

The application follows a clean architecture pattern organized into the following directories:

### [config/](lib/config/)
Contains application configuration and global settings
- `theme.dart` - Defines the app's color scheme, typography, and overall theme
- `routes.dart` - Declares all application routes using GetX navigation

### [controllers/](lib/controllers/)
Contains GetX controllers that handle business logic and state management
- `auth_controller.dart` - Manages user authentication state and operations (login, register)
- `cart_controller.dart` - Handles shopping cart functionality (add/remove items, calculate totals)
- `wishlist_controller.dart` - Manages wishlist operations (add/remove products)
- `order_controller.dart` - Handles order data and status management
- `api_controller.dart` - Manages API implementation toggle (Dio vs http) and runtime measurements

### [models/](lib/models/)
Contains data models that represent the application's data structures
- `user.dart` - Defines the User model with authentication-related fields
- `product.dart` - Defines the Product model with details like name, price, images, specifications
- `cart_item.dart` - Represents items in the shopping cart with quantity tracking
- `order.dart` - Defines order structures including items, status, and payment details

### [services/](lib/services/)
Contains service classes that handle external communications and business operations
- `product_service.dart` - Manages product API calls with support for both Dio and http packages

### [views/](lib/views/)
Contains all UI screens organized by feature areas
- `auth/` - Authentication screens (login, register)
- `cart/` - Shopping cart and checkout screens
- `history/` - Order history and transaction screens
- `home/` - Main home screen with navigation
- `product/` - Product listing, detail, and search screens
- `profile/` - User profile management screen
- `wishlist/` - Wishlist management screen
- `splash_screen.dart` - Initial splash screen with app branding

### [widgets/](lib/widgets/)
Contains reusable UI components and custom widgets
- `bottom_nav_bar.dart` - Custom bottom navigation bar with badge indicators
- `category_chip.dart` - Interactive category filter chips
- `custom_app_bar.dart` - Reusable app bar with cart and search functions
- `hero_banner.dart` - Carousel banner for promotions and featured items
- `product_card.dart` - Display card for products with image, price, and wishlist functionality

## Architecture & Technologies

- **Framework**: Flutter
- **State Management**: GetX
- **Architecture Pattern**: MVVM (Model-View-Controller with GetX)
- **Navigation**: GetX routing system
- **API**: Both http and Dio support with toggleable implementation

## Features

- User authentication (Login/Register)
- Product browsing and search
- Shopping cart functionality
- Wishlist management
- Order management
- Checkout process with multiple payment options
- API toggle (Dio vs http)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
