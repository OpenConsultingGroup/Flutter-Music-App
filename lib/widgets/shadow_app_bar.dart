import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

const double _kLeadingWidth = kToolbarHeight; // So the leading button is square.

// Bottom justify the kToolbarHeight child which may overflow the top.
class _ToolbarContainerLayout extends SingleChildLayoutDelegate {
  const _ToolbarContainerLayout();

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(height: kToolbarHeight);
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, kToolbarHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(_ToolbarContainerLayout oldDelegate) => false;
}

class ShadowAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Creates a material design app bar.
  ///
  /// The arguments [elevation], [primary], [toolbarOpacity], [bottomOpacity]
  /// and [automaticallyImplyLeading] must not be null.
  ///
  /// Typically used in the [Scaffold.appBar] property.
  ShadowAppBar({
    Key key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation = 4.0,
    this.backgroundColor,
    this.brightness,
    this.iconTheme,
    this.textTheme,
    this.primary = true,
    this.centerTitle,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
  }) : assert(automaticallyImplyLeading != null),
        assert(elevation != null),
        assert(primary != null),
        assert(titleSpacing != null),
        assert(toolbarOpacity != null),
        assert(bottomOpacity != null),
        preferredSize = Size.fromHeight(kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)),
        _shadowAppBarState=_ShadowAppBarState(title),
        super(key: key);

  final IconButton leading;
  final bool automaticallyImplyLeading;
  final String title;

  final List<Widget> actions;
  final Widget flexibleSpace;
  final PreferredSizeWidget bottom;
  final double elevation;

  final Color backgroundColor;

  final Brightness brightness;
  final IconThemeData iconTheme;
  final TextTheme textTheme;

  final bool primary;

  final bool centerTitle;

  final double titleSpacing;

  final double toolbarOpacity;
  final double bottomOpacity;

  @override
  final Size preferredSize;

  Color shadowColor =Colors.transparent;

  bool _getEffectiveCenterTitle(ThemeData themeData) {
    if (centerTitle != null)
      return centerTitle;
    assert(themeData.platform != null);
    switch (themeData.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return false;
      case TargetPlatform.iOS:
        return actions == null || actions.length < 2;
    }
    return null;
  }
  final _ShadowAppBarState _shadowAppBarState;
  @override
  _ShadowAppBarState createState() => _shadowAppBarState;

  void changeBackgroundColor(Color color)
  {
    _shadowAppBarState.changeBackgroundColor(color);
  }
  void changeTitle(String title)
  {
    _shadowAppBarState.changeTitle(title);
  }
  void changeHeight(double height)
  {
    _shadowAppBarState.changeHeight(height);
  }
  void createShadow()
  {
    _shadowAppBarState.createShadow();
  }
  void removeShadow()
  {
    _shadowAppBarState.removeShadow();
  }
  bool isShadowExists()
  {
    return shadowColor==Colors.black26;
  }
}

class _ShadowAppBarState extends State<ShadowAppBar> with SingleTickerProviderStateMixin {
  Color color=Colors.transparent;
  String title;
  Color statusBarColor;
  double height=125.0;
  double opacity=1.0;

  Animation<double>animation;
  AnimationController animationController;

  _ShadowAppBarState(this.title){
    this.statusBarColor=Colors.white;
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin:0.0, end: 1.0).animate(animationController);
    animationController.forward();
  }

  get secondaryColor => Colors.black;

  void _handleDrawerButton() {
    Scaffold.of(context).openDrawer();
  }

  void _handleDrawerButtonEnd() {
    Scaffold.of(context).openEndDrawer();
  }
  void createShadow()
  {
    setState(() {
      widget.shadowColor=Colors.black26;
    });
  }
  void removeShadow()
  {
    setState(() {
      widget.shadowColor=Colors.transparent;
    });
  }
  void changeBackgroundColor(Color color) {
    setState(() {
      this.statusBarColor=color;
    });
  }

  void changeTitle(String title)
  {
    setState(() {
      this.opacity=1.0;
      this.title=title;
    });
  }
  void changeHeight(double height) {
   setState(() {
     this.height=height;
   });
  }
  @override
  Widget build(BuildContext context) {
    assert(!widget.primary || debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final ThemeData themeData = Theme.of(context);
    final ScaffoldState scaffold = Scaffold.of(context, nullOk: true);
    final ModalRoute<dynamic> parentRoute = ModalRoute.of(context);

    final bool hasDrawer = scaffold?.hasDrawer ?? false;
    final bool hasEndDrawer = scaffold?.hasEndDrawer ?? false;
    final bool canPop = parentRoute?.canPop ?? false;
    final bool useCloseButton = parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;
    IconThemeData iconThemeData=IconThemeData(color: this.secondaryColor);
    IconThemeData appBarIconTheme = widget.iconTheme ?? iconThemeData?? themeData.primaryIconTheme;
    TextStyle centerStyle = widget.textTheme?.title ?? themeData.primaryTextTheme.title;
    TextStyle sideStyle = widget.textTheme?.body1 ?? themeData.primaryTextTheme.body1;

    if (widget.toolbarOpacity != 1.0) {
      final double opacity = const Interval(0.25, 1.0, curve: Curves.fastOutSlowIn).transform(widget.toolbarOpacity);
      if (centerStyle?.color != null)
        centerStyle = centerStyle.copyWith(color: centerStyle.color.withOpacity(opacity));
      if (sideStyle?.color != null)
        sideStyle = sideStyle.copyWith(color: sideStyle.color.withOpacity(opacity));
      appBarIconTheme = appBarIconTheme.copyWith(
          opacity: opacity * (appBarIconTheme.opacity ?? 1.0)
      );
    }

    Widget leading = widget.leading;
    if (leading == null && widget.automaticallyImplyLeading) {
      if (hasDrawer) {
        leading = IconButton(
          icon: Icon(Icons.menu,color: this.secondaryColor,),
          onPressed: _handleDrawerButton,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      } else {
        if (canPop)
          leading = useCloseButton ? const CloseButton() : const BackButton();
      }
    }
    if (leading != null) {
      leading = ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: _kLeadingWidth),
        child: IconButton(icon: Icon(Icons.menu,color: this.secondaryColor,),color: this.secondaryColor, onPressed: null),
      );
    }

    Widget title = AnimatedOpacity(child: Text(this.title,style: TextStyle(fontSize: 17.0,color: secondaryColor)), duration: Duration(seconds: 2), opacity: this.opacity,);
    if (title != null) {
      bool namesRoute;
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
          namesRoute = true;
          break;
        case TargetPlatform.iOS:
          break;
      }
      title = DefaultTextStyle(
        style: centerStyle,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: Semantics(
          namesRoute: namesRoute,
          child: title,
          header: true,
        ),
      );
    }

    Widget actions;
    if (widget.actions != null && widget.actions.isNotEmpty) {
      actions = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.actions,
      );
    } else if (hasEndDrawer) {
      actions = IconButton(
        icon: const Icon(Icons.menu),
        onPressed: _handleDrawerButtonEnd,
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      );
    }

    final Widget toolbar = NavigationToolbar(
      leading: leading,
      middle: title,
      trailing: actions,
      centerMiddle: widget._getEffectiveCenterTitle(themeData),
      middleSpacing: widget.titleSpacing,
    );

    // If the toolbar is allocated less than kToolbarHeight make it
    // appear to scroll upwards within its shrinking container.
    Widget appBar = ClipRect(
      child: CustomSingleChildLayout(
        delegate: const _ToolbarContainerLayout(),
        child: IconTheme.merge(
          data: appBarIconTheme,
          child: DefaultTextStyle(
            style: sideStyle,
            child: toolbar,
          ),
        ),
      ),
    );
    if (widget.bottom != null) {
      appBar = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: kToolbarHeight),
              child: appBar,
            ),
          ),
          widget.bottomOpacity == 1.0 ? widget.bottom : Opacity(
            opacity: const Interval(0.25, 1.0, curve: Curves.fastOutSlowIn).transform(widget.bottomOpacity),
            child: widget.bottom,
          ),
        ],
      );
    }

    // The padding applies to the toolbar and tabbar, not the flexible space.
    if (widget.primary) {
      appBar = SafeArea(
        top: true,
        child: appBar,
      );
    }

    appBar = Align(
      alignment: Alignment.topCenter,
      child: appBar,
    );

    if (widget.flexibleSpace != null) {
      appBar = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          widget.flexibleSpace,
          appBar,
        ],
      );
    }
    final Brightness brightness = widget.brightness??(this.statusBarColor==Colors.white?Brightness.light:Brightness.dark) ?? themeData.primaryColorBrightness;
    final SystemUiOverlayStyle overlayStyle = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light.copyWith(statusBarColor: this.statusBarColor)
        : SystemUiOverlayStyle.dark.copyWith(statusBarColor: this.statusBarColor);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Material(
          color: widget.backgroundColor ?? themeData.primaryColor,
          elevation: widget.elevation,
          child: AnimatedContainer(duration: Duration(milliseconds: 400),child: appBar,decoration: BoxDecoration(color:Colors.white,boxShadow: [BoxShadow(color: widget.shadowColor,spreadRadius: 4.0,blurRadius: 10.0)]),),
        ),
      ),
    );
    }



}
