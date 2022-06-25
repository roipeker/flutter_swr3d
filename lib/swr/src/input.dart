part of swr;

///
/// This implementations are meant to satisfy Java's KeyEvent
/// and MouseEvent interface.
///
class MouseEvent {
  final double _x, _y;
  final int _button;
  const MouseEvent(this._x, this._y, this._button);

  int getX() => _x.floor();

  int getY() => _y.floor();

  int getButton() => _button;
}

typedef KeyData = PhysicalKeyboardKey;

// implements KeyListener, FocusListener,
//     MouseListener, MouseMotionListener
class Input {
  Set<int> keys = <int>{};
  List<bool> mouseButtons = List.filled(4, false);
  int mouseX = 0;
  int mouseY = 0;

  /// Updates state when the mouse is dragged
  void mouseDragged(MouseEvent e) {
    mouseX = e.getX();
    mouseY = e.getY();
  }

  /// Updates state when the mouse is moved
  void mouseMoved(MouseEvent e) {
    mouseX = e.getX();
    mouseY = e.getY();
  }

  /// Updates state when the mouse is clicked
  void mouseClicked(MouseEvent e) {}

  /// Updates state when the mouse enters the screen
  void mouseEntered(MouseEvent e) {}

  /// Updates state when the mouse exits the screen
  void mouseExited(MouseEvent e) {}

  /// Updates state when a mouse button is pressed
  void mousePressed(MouseEvent e) {
    int code = e.getButton();
    if (code > 0 && code < mouseButtons.length) {
      mouseButtons[code] = true;
    }
    mouseX = e.getX();
    mouseY = e.getY();
  }

  /// Clears the state when a mouse button is released.
  /// In macos, I couldn't get the mouseUp button code independently.
  /// TODO: revisit this implementation for Flutter.
  void mouseReleased(MouseEvent e) {
    // int code = e.getButton();
    mouseButtons.fillRange(0, mouseButtons.length-1,false);
  }

  /// Updates state when a key is pressed
  void keyPressed(PhysicalKeyboardKey key) {
    keys.add(key.usbHidUsage);
  }

  /// Updates state when a key is released
  void keyReleased(PhysicalKeyboardKey key) {
    keys.remove(key.usbHidUsage);
  }

  /// Gets whether or not a particular key is currently pressed.
  ///
  /// @param key The key to test
  /// @return Whether or not key is currently pressed.
  bool getKey(KeyData key) => keys.contains(key.usbHidUsage);

  /// Gets whether or not a particular mouse button is currently pressed.
  ///
  /// @param button The button to test
  /// @return Whether or not the button is currently pressed.
  bool getMouse(int button) => mouseButtons[button];

  /// Gets the location of the mouse cursor on x, in pixels.
  /// @return The location of the mouse cursor on x, in pixels
  int getMouseX() => mouseX;

  /// Gets the location of the mouse cursor on y, in pixels.
  /// @return The location of the mouse cursor on y, in pixels
  int getMouseY() => mouseY;
}
