package lime.system;

/**
 * Represents the current power/battery state of the device
 */
enum PowerState
{
	/**
	 * Cannot determine power status
	 */
	UNKNOWN;

	/**
	 * Running on battery power
	 */
	ON_BATTERY;

	/**
	 * Plugged in, no battery available
	 */
	NO_BATTERY;

	/**
	 * Plugged in and charging battery
	 */
	CHARGING;

	/**
	 * Plugged in and battery is fully charged
	 */
	CHARGED;
}
