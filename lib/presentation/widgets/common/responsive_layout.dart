import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// A responsive layout widget that adapts to different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppTheme.tabletBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= AppTheme.mobileBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// A responsive container that adjusts its layout based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        EdgeInsets responsivePadding;
        if (padding != null) {
          responsivePadding = padding!;
        } else if (constraints.maxWidth < AppTheme.mobileBreakpoint) {
          responsivePadding = const EdgeInsets.all(16);
        } else if (constraints.maxWidth < AppTheme.tabletBreakpoint) {
          responsivePadding = const EdgeInsets.all(24);
        } else {
          responsivePadding = const EdgeInsets.all(32);
        }

        double responsiveMaxWidth;
        if (maxWidth != null) {
          responsiveMaxWidth = maxWidth!;
        } else if (constraints.maxWidth < AppTheme.mobileBreakpoint) {
          responsiveMaxWidth = constraints.maxWidth;
        } else if (constraints.maxWidth < AppTheme.tabletBreakpoint) {
          responsiveMaxWidth = constraints.maxWidth * 0.8;
        } else {
          responsiveMaxWidth = 1200;
        }

        Widget content = Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: responsiveMaxWidth),
          padding: responsivePadding,
          child: child,
        );

        if (centerContent && constraints.maxWidth >= AppTheme.mobileBreakpoint) {
          content = Center(child: content);
        }

        return content;
      },
    );
  }
}

/// A responsive grid that adjusts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        if (constraints.maxWidth >= AppTheme.tabletBreakpoint) {
          columns = desktopColumns ?? 3;
        } else if (constraints.maxWidth >= AppTheme.mobileBreakpoint) {
          columns = tabletColumns ?? 2;
        } else {
          columns = mobileColumns ?? 1;
        }

        return ResponsiveContainer(
          padding: padding,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
              childAspectRatio: 1.0,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        );
      },
    );
  }
}

/// A responsive row that stacks items vertically on mobile
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final bool forceVertical;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 16,
    this.forceVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (forceVertical || constraints.maxWidth < AppTheme.mobileBreakpoint) {
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children
                .expand((child) => [child, SizedBox(height: spacing)])
                .take(children.length * 2 - 1)
                .toList(),
          );
        }

        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children
              .expand((child) => [child, SizedBox(width: spacing)])
              .take(children.length * 2 - 1)
              .toList(),
        );
      },
    );
  }
}

/// A responsive card that adjusts its layout based on screen size
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? color;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? 
        (AppTheme.isMobile(context) 
            ? const EdgeInsets.all(16) 
            : const EdgeInsets.all(24));

    return Card(
      elevation: elevation,
      color: color,
      margin: margin ?? const EdgeInsets.all(8),
      child: Padding(
        padding: responsivePadding,
        child: child,
      ),
    );
  }
}

/// A responsive scaffold that adapts to different screen sizes and orientations
class ResponsiveScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final isTabletOrDesktop = AppTheme.isTablet(context) || AppTheme.isDesktop(context);

    // On tablets/desktop in landscape, use rail navigation instead of drawer
    if (isTabletOrDesktop && isLandscape && drawer != null) {
      return Scaffold(
        appBar: appBar as PreferredSizeWidget?,
        body: Row(
          children: [
            // Convert drawer to navigation rail
            _buildNavigationRail(context),
            Expanded(
              child: ResponsiveContainer(
                child: body,
              ),
            ),
          ],
        ),
        endDrawer: endDrawer,
        floatingActionButton: floatingActionButton,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      );
    }

    return Scaffold(
      appBar: appBar as PreferredSizeWidget?,
      body: ResponsiveContainer(child: body),
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    // This is a simplified navigation rail
    // In a real implementation, you'd extract navigation items from the drawer
    return NavigationRail(
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
      selectedIndex: 0,
      onDestinationSelected: (index) {
        // Handle navigation
      },
    );
  }
}

/// A responsive form layout that adapts field arrangement based on screen size
class ResponsiveForm extends StatelessWidget {
  final List<Widget> fields;
  final EdgeInsets? padding;
  final double spacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;

  const ResponsiveForm({
    super.key,
    required this.fields,
    this.padding,
    this.spacing = 16,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    
    int columns;
    if (screenWidth >= AppTheme.tabletBreakpoint) {
      columns = desktopColumns ?? 3;
    } else if (screenWidth >= AppTheme.mobileBreakpoint) {
      columns = tabletColumns ?? 2;
    } else {
      columns = mobileColumns ?? 1;
    }

    return Padding(
      padding: padding ?? AppTheme.getResponsivePadding(context),
      child: columns == 1
          ? Column(
              children: fields
                  .expand((field) => [field, SizedBox(height: spacing)])
                  .take(fields.length * 2 - 1)
                  .toList(),
            )
          : Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: fields.map((field) => 
                SizedBox(
                  width: (screenWidth - (columns + 1) * spacing) / columns,
                  child: field,
                ),
              ).toList(),
            ),
    );
  }
}

/// A responsive dialog that adapts its size and position based on screen size
class ResponsiveDialog extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final EdgeInsets? contentPadding;

  const ResponsiveDialog({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = AppTheme.isMobile(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // On mobile in portrait, use full-screen dialog
    if (isMobile && !isLandscape) {
      return Scaffold(
        appBar: AppBar(
          title: title != null ? Text(title!) : null,
          actions: actions?.map((action) => 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: action,
            ),
          ).toList(),
        ),
        body: Padding(
          padding: contentPadding ?? const EdgeInsets.all(16),
          child: child,
        ),
      );
    }

    // On larger screens or landscape, use standard dialog
    return AlertDialog(
      title: title != null ? Text(title!) : null,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? mediaQuery.size.width * 0.9 : 600,
          maxHeight: mediaQuery.size.height * 0.8,
        ),
        child: child,
      ),
      actions: actions,
      contentPadding: contentPadding ?? const EdgeInsets.all(24),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    EdgeInsets? contentPadding,
  }) {
    final isMobile = AppTheme.isMobile(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isMobile && !isLandscape) {
      return Navigator.of(context).push<T>(
        MaterialPageRoute(
          builder: (context) => ResponsiveDialog(
            title: title,
            actions: actions,
            contentPadding: contentPadding,
            child: child,
          ),
          fullscreenDialog: true,
        ),
      );
    }

    return showDialog<T>(
      context: context,
      builder: (context) => ResponsiveDialog(
        title: title,
        actions: actions,
        contentPadding: contentPadding,
        child: child,
      ),
    );
  }
}