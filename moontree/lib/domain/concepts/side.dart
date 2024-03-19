enum Side {
  left,
  right,
  top,
  bottom,
  none;

  Side get opposite {
    switch (this) {
      case Side.left:
        return Side.right;
      case Side.right:
        return Side.left;
      case Side.top:
        return Side.bottom;
      case Side.bottom:
        return Side.top;
      case Side.none:
        return Side.none;
    }
  }
}
