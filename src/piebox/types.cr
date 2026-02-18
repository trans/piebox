module Piebox
  enum BookType
    Comic       # left-to-right, top-to-bottom flow
    PictureBook # no flow constraint
  end

  enum Significance
    Climax # full page
    Epic   # 1/2, 1/3, or 1/4 page
    Normal # 1/6 page, expandable to 1/3
  end

  @[Flags]
  enum Modifier
    Vista  # wider than tall
    Action # convey action via preset style
  end

  enum ActionStyle
    Split3      # 3-pane horizontal split
    ZoomIn      # progressive zoom sequence
    MotionLines # speed/motion line overlay
  end
end
