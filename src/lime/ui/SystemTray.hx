package lime.ui;

#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end
import lime.app.Event;

/**
 * System tray/notification area icon support
 *
 * Allows applications to add icons to the system tray with tooltips,
 * click handlers, and context menus.
 */
@:access(lime._internal.backend.native.NativeCFFI)
class SystemTray
{
	/**
	 * Event dispatched when the tray icon is clicked
	 */
	public var onClick(default, null) = new Event<Void->Void>();

	/**
	 * Event dispatched when the tray icon is right-clicked
	 */
	public var onRightClick(default, null) = new Event<Void->Void>();

	/**
	 * The tooltip text displayed when hovering over the tray icon
	 */
	public var tooltip(default, set):String;

	/**
	 * Whether the tray icon is currently visible
	 */
	public var visible(get, set):Bool;

	private var __tooltip:String = "";
	private var __visible:Bool = false;
	private var __handle:Dynamic;

	/**
	 * Creates a new system tray icon
	 * @param iconPath Path to the icon file (PNG, ICO, etc.)
	 * @param tooltip Initial tooltip text
	 */
	public function new(iconPath:String = "", tooltip:String = "")
	{
		this.__tooltip = tooltip;

		#if (lime_cffi && !macro)
		__handle = NativeCFFI.lime_system_tray_create(iconPath, tooltip);
		if (__handle != null)
		{
			__visible = true;
		}
		#end
	}

	/**
	 * Shows the tray icon
	 */
	public function show():Void
	{
		#if (lime_cffi && !macro)
		if (__handle != null)
		{
			NativeCFFI.lime_system_tray_show(__handle);
			__visible = true;
		}
		#end
	}

	/**
	 * Hides the tray icon
	 */
	public function hide():Void
	{
		#if (lime_cffi && !macro)
		if (__handle != null)
		{
			NativeCFFI.lime_system_tray_hide(__handle);
			__visible = false;
		}
		#end
	}

	/**
	 * Updates the tray icon image
	 * @param iconPath Path to the new icon file
	 */
	public function setIcon(iconPath:String):Void
	{
		#if (lime_cffi && !macro)
		if (__handle != null)
		{
			NativeCFFI.lime_system_tray_set_icon(__handle, iconPath);
		}
		#end
	}

	/**
	 * Destroys the tray icon and frees resources
	 */
	public function destroy():Void
	{
		#if (lime_cffi && !macro)
		if (__handle != null)
		{
			NativeCFFI.lime_system_tray_destroy(__handle);
			__handle = null;
			__visible = false;
		}
		#end
	}

	// Getters/Setters

	private function get_visible():Bool
	{
		return __visible;
	}

	private function set_visible(value:Bool):Bool
	{
		if (value)
		{
			show();
		}
		else
		{
			hide();
		}
		return __visible;
	}

	private function set_tooltip(value:String):String
	{
		__tooltip = value;

		#if (lime_cffi && !macro)
		if (__handle != null)
		{
			NativeCFFI.lime_system_tray_set_tooltip(__handle, value);
		}
		#end

		return __tooltip;
	}
}
