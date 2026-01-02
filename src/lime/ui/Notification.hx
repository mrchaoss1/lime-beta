package lime.ui;

#if (!lime_doc_gen || lime_cffi)
import lime._internal.backend.native.NativeCFFI;
#end

/**
 * Native desktop notification support
 *
 * Displays system notifications on supported platforms (Linux, Windows, macOS)
 */
@:access(lime._internal.backend.native.NativeCFFI)
class Notification
{
	/**
	 * The notification title
	 */
	public var title:String;

	/**
	 * The notification body text
	 */
	public var body:String;

	/**
	 * The notification icon path (optional)
	 */
	public var icon:String;

	/**
	 * Creates a new notification
	 * @param title The notification title
	 * @param body The notification body text
	 * @param icon The notification icon path (optional)
	 */
	public function new(title:String, body:String = "", icon:String = "")
	{
		this.title = title;
		this.body = body;
		this.icon = icon;
	}

	/**
	 * Shows the notification
	 * @return true if the notification was shown successfully
	 */
	public function show():Bool
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_notification_show(title, body, icon);
		#else
		trace('Notification: $title - $body');
		return false;
		#end
	}

	/**
	 * Shows a simple notification with just a title and body
	 * @param title The notification title
	 * @param body The notification body text
	 * @param icon The notification icon path (optional)
	 * @return true if the notification was shown successfully
	 */
	public static function showSimple(title:String, body:String = "", icon:String = ""):Bool
	{
		var notification = new Notification(title, body, icon);
		return notification.show();
	}
}
