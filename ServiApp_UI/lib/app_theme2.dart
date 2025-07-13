import 'package:flutter/material.dart';

class ServiceAppTheme {
  // ============ PALETA DE COLORES PRINCIPAL ============
  
  // Azules principales - tonos suaves y profesionales
  static const Color primaryBlue = Color(0xFF4A90E2);          // Azul principal elegante
  static const Color secondaryBlue = Color(0xFF6BB6FF);        // Azul secundario más claro
  static const Color accentBlue = Color(0xFF87CEEB);           // Azul accent suave
  static const Color lightBlue = Color(0xFFE3F2FD);           // Azul muy claro para backgrounds
  static const Color darkBlue = Color(0xFF2C3E50);            // Azul oscuro para textos importantes
  
  // Colores complementarios
  static const Color backgroundColor = Color(0xFFF8FAFB);      // Fondo principal
  static const Color surfaceColor = Color(0xFFFFFFFF);        // Superficie de cards
  static const Color cardColor = Color(0xFFFFFFFF);           // Color de tarjetas
  static const Color dividerColor = Color(0xFFE0E8F0);       // Divisores suaves
  
  // Colores de estado
  static const Color successColor = Color(0xFF4CAF50);        // Verde para éxito
  static const Color warningColor = Color(0xFFFF9800);        // Naranja para advertencias  
  static const Color errorColor = Color(0xFFF44336);          // Rojo para errores
  static const Color infoColor = Color(0xFF2196F3);           // Azul para información
  
  // Colores de texto
  static const Color primaryTextColor = Color(0xFF1A1A1A);    // Texto principal
  static const Color secondaryTextColor = Color(0xFF6B7280);  // Texto secundario
  static const Color mutedTextColor = Color(0xFF9CA3AF);      // Texto tenue
  static const Color onPrimaryTextColor = Color(0xFFFFFFFF);  // Texto sobre azul
  
  // ============ GRADIENTES ELEGANTES ============
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A90E2),
      Color(0xFF6BB6FF),
    ],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FAFB),
    ],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient serviceCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF0F7FF),
    ],
    stops: [0.0, 1.0],
  );
  
  // ============ SOMBRAS PROFESIONALES ============
  
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A4A90E2),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x154A90E2),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x204A90E2),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
  
  // ============ TEMA PRINCIPAL ============
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: dividerColor,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: onPrimaryTextColor,
        onSecondary: onPrimaryTextColor,
        onSurface: primaryTextColor,
        onBackground: primaryTextColor,
        onError: onPrimaryTextColor,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: onPrimaryTextColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onPrimaryTextColor,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(
          color: onPrimaryTextColor,
          size: 24,
        ),
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarTheme(
        labelColor: onPrimaryTextColor,
        unselectedLabelColor: Color(0xB3FFFFFF),
        indicatorColor: accentBlue,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: onPrimaryTextColor,
          elevation: 4,
          shadowColor: primaryBlue.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: const CardTheme(
        elevation: 4,
        shadowColor: Color(0x0A4A90E2),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(
          color: secondaryTextColor,
          fontSize: 16,
        ),
        hintStyle: const TextStyle(
          color: mutedTextColor,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ============ WIDGETS PERSONALIZADOS ============

class ServiceAppWidgets {
  
  // ============ TARJETA DE SERVICIO MEJORADA ============
  
  static Widget buildServiceCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    List<BoxShadow>? boxShadow,
    bool useGradient = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: useGradient ? ServiceAppTheme.serviceCardGradient : null,
        color: useGradient ? null : (backgroundColor ?? ServiceAppTheme.cardColor),
        borderRadius: BorderRadius.circular(18),
        boxShadow: boxShadow ?? ServiceAppTheme.cardShadow,
        border: Border.all(
          color: ServiceAppTheme.dividerColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
  
  // ============ TARJETA DE PROVEEDOR ============
  
  static Widget buildProviderCard({
    required String providerName,
    required String location,
    required double rating,
    required int totalRatings,
    String? profileImage,
    VoidCallback? onTap,
    List<Widget>? actions,
  }) {
    return buildServiceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del proveedor
          Row(
            children: [
              // Avatar del proveedor
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ServiceAppTheme.primaryGradient,
                  boxShadow: ServiceAppTheme.softShadow,
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: profileImage != null && profileImage.isNotEmpty
                        ? Image.network(
                            profileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, size: 28, color: ServiceAppTheme.mutedTextColor),
                          )
                        : const Icon(Icons.person, size: 28, color: ServiceAppTheme.mutedTextColor),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Información del proveedor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ServiceAppTheme.primaryTextColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: ServiceAppTheme.mutedTextColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: ServiceAppTheme.secondaryTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildRatingRow(rating, totalRatings),
                  ],
                ),
              ),
            ],
          ),
          
          // Acciones si se proporcionan
          if (actions != null && actions.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(color: ServiceAppTheme.dividerColor, height: 1),
            const SizedBox(height: 16),
            Row(
              children: actions.map((action) => Expanded(child: action)).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  // ============ TARJETA DE ESTADÍSTICA ============
  
  static Widget buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    Color? iconColor,
    Color? backgroundColor,
    bool showTrend = false,
    double? trendValue,
  }) {
    final color = iconColor ?? ServiceAppTheme.primaryBlue;
    
    return buildServiceCard(
      backgroundColor: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono con fondo circular
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          
          // Valor
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: ServiceAppTheme.primaryTextColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          
          // Título
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: ServiceAppTheme.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Tendencia opcional
          if (showTrend && trendValue != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  trendValue >= 0 ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: trendValue >= 0 ? ServiceAppTheme.successColor : ServiceAppTheme.errorColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${trendValue.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trendValue >= 0 ? ServiceAppTheme.successColor : ServiceAppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  // ============ BOTONES PERSONALIZADOS ============
  
  static Widget buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: ServiceAppTheme.buttonShadow,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ServiceAppTheme.primaryBlue,
          foregroundColor: ServiceAppTheme.onPrimaryTextColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  static Widget buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Color? color,
    double? width,
  }) {
    final buttonColor = color ?? ServiceAppTheme.secondaryBlue;
    
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // ============ BOTONES DE ACCIÓN (LLAMAR/WHATSAPP) ============
  
  static Widget buildActionButtonsRow({
    required VoidCallback onCallPressed,
    required VoidCallback onWhatsAppPressed,
    bool isLoading = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: buildPrimaryButton(
            text: 'Llamar',
            onPressed: onCallPressed,
            icon: Icons.phone,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF25D366).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onWhatsAppPressed,
              icon: const Icon(Icons.chat, size: 20),
              label: const Text(
                'WhatsApp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // ============ HEADER DE SECCIÓN ============
  
  static Widget buildSectionHeader({
    required String title,
    String? subtitle,
    Widget? action,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: ServiceAppTheme.primaryTextColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 16,
                          color: ServiceAppTheme.secondaryTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) action,
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ServiceAppTheme.dividerColor.withOpacity(0),
                  ServiceAppTheme.dividerColor,
                  ServiceAppTheme.dividerColor.withOpacity(0),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  // ============ ESTADO VACÍO ============
  
  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
    Color? iconColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (iconColor ?? ServiceAppTheme.mutedTextColor).withOpacity(0.1),
                    (iconColor ?? ServiceAppTheme.mutedTextColor).withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? ServiceAppTheme.mutedTextColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ServiceAppTheme.primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: ServiceAppTheme.secondaryTextColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 32),
              action,
            ],
          ],
        ),
      ),
    );
  }
  
  // ============ INDICADOR DE CARGA ============
  
  static Widget buildLoadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ServiceAppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ServiceAppTheme.softShadow,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ServiceAppTheme.primaryBlue),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                color: ServiceAppTheme.secondaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
  
  // ============ HELPERS PRIVADOS ============
  
  static Widget _buildRatingRow(double rating, int totalRatings) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating.floor() 
                ? Icons.star_rounded 
                : (index < rating) 
                    ? Icons.star_half_rounded 
                    : Icons.star_outline_rounded,
            size: 16,
            color: const Color(0xFFFFB800),
          );
        }),
        const SizedBox(width: 8),
        Text(
          '${rating.toStringAsFixed(1)} (${totalRatings})',
          style: const TextStyle(
            fontSize: 14,
            color: ServiceAppTheme.secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============ EXTENSIONES ÚTILES ============

extension ServiceColorExtension on Color {
  Color get lighten => Color.alphaBlend(Colors.white.withOpacity(0.3), this);
  Color get darken => Color.alphaBlend(Colors.black.withOpacity(0.2), this);
  
  Color withOpacityCustom(double opacity) {
    return withOpacity(opacity.clamp(0.0, 1.0));
  }
}

// ============ CONSTANTES DE DISEÑO ============

class ServiceSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

class ServiceRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
}

class ServiceTextStyles {
  static const TextStyle hero = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: ServiceAppTheme.primaryTextColor,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: ServiceAppTheme.primaryTextColor,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: ServiceAppTheme.primaryTextColor,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: ServiceAppTheme.primaryTextColor,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: ServiceAppTheme.primaryTextColor,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ServiceAppTheme.primaryTextColor,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ServiceAppTheme.secondaryTextColor,
    height: 1.4,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ServiceAppTheme.mutedTextColor,
    letterSpacing: 0.5,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}