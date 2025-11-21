.PHONY: help run-staging run-prod build-staging build-prod build-staging-apk build-prod-apk clean

help:
	@echo "🚀 Sun POS - Flutter Flavor Commands"
	@echo ""
	@echo "📱 Run Commands:"
	@echo "  make run-staging       - Run app in staging environment"
	@echo "  make run-prod          - Run app in production environment"
	@echo ""
	@echo "🔨 Build APK Commands:"
	@echo "  make build-staging-apk - Build staging APK (release mode)"
	@echo "  make build-prod-apk    - Build production APK (release mode)"
	@echo ""
	@echo "🔨 Build AAB Commands (for Play Store):"
	@echo "  make build-staging     - Build staging AAB (release mode)"
	@echo "  make build-prod        - Build production AAB (release mode)"
	@echo ""
	@echo "🧹 Clean:"
	@echo "  make clean             - Clean build files"
	@echo ""

# Run staging environment
run-staging:
	@echo "🏃 Running Sun POS (Staging)..."
	flutter run --dart-define=ENV=staging --flavor staging

# Run production environment
run-prod:
	@echo "🏃 Running Sun POS (Production)..."
	flutter run --dart-define=ENV=production --flavor production

# Build staging APK
build-staging-apk:
	@echo "🔨 Building Staging APK..."
	flutter build apk --dart-define=ENV=staging --flavor staging --release
	@echo "✅ Staging APK built successfully!"
	@echo "📦 Location: build/app/outputs/flutter-apk/app-staging-release.apk"

# Build production APK
build-prod-apk:
	@echo "🔨 Building Production APK..."
	flutter build apk --dart-define=ENV=production --flavor production --release
	@echo "✅ Production APK built successfully!"
	@echo "📦 Location: build/app/outputs/flutter-apk/app-production-release.apk"

# Build staging AAB (Android App Bundle for Play Store)
build-staging:
	@echo "🔨 Building Staging AAB..."
	flutter build appbundle --dart-define=ENV=staging --flavor staging --release
	@echo "✅ Staging AAB built successfully!"
	@echo "📦 Location: build/app/outputs/bundle/stagingRelease/app-staging-release.aab"

# Build production AAB (Android App Bundle for Play Store)
build-prod:
	@echo "🔨 Building Production AAB..."
	flutter build appbundle --dart-define=ENV=production --flavor production --release
	@echo "✅ Production AAB built successfully!"
	@echo "📦 Location: build/app/outputs/bundle/productionRelease/app-production-release.aab"

# Clean build files
clean:
	@echo "🧹 Cleaning build files..."
	flutter clean
	@echo "✅ Clean completed!"
