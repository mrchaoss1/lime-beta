package lime.utils;

import haxe.PosInfos;

/**
 * Enhanced pretty output formatter for Lime build system
 * Provides colors, progress indicators, and better formatting
 */
class PrettyOutput
{
	// ANSI Color codes
	public static var enableColors:Bool = true;

	private static inline var RESET = "\x1b[0m";
	private static inline var BOLD = "\x1b[1m";
	private static inline var DIM = "\x1b[2m";

	// Colors
	private static inline var BLACK = "\x1b[30m";
	private static inline var RED = "\x1b[31m";
	private static inline var GREEN = "\x1b[32m";
	private static inline var YELLOW = "\x1b[33m";
	private static inline var BLUE = "\x1b[34m";
	private static inline var MAGENTA = "\x1b[35m";
	private static inline var CYAN = "\x1b[36m";
	private static inline var WHITE = "\x1b[37m";

	// Background colors
	private static inline var BG_RED = "\x1b[41m";
	private static inline var BG_GREEN = "\x1b[42m";
	private static inline var BG_YELLOW = "\x1b[43m";
	private static inline var BG_BLUE = "\x1b[44m";

	// Symbols/Icons
	private static inline var ICON_INFO = "ℹ";
	private static inline var ICON_SUCCESS = "✓";
	private static inline var ICON_ERROR = "✗";
	private static inline var ICON_WARNING = "⚠";
	private static inline var ICON_BUILD = "🔨";
	private static inline var ICON_ROCKET = "🚀";
	private static inline var ICON_TIME = "⏱";
	private static inline var ICON_FILE = "📄";

	private static var startTime:Float = 0;
	private static var lastStepTime:Float = 0;
	private static var currentStep:Int = 0;
	private static var totalSteps:Int = 0;

	/**
	 * Initialize pretty output (call at start of build)
	 */
	public static function init(?steps:Int):Void
	{
		#if sys
		// Check if terminal supports colors
		enableColors = Sys.getEnv("TERM") != null && Sys.getEnv("TERM") != "dumb";
		if (Sys.getEnv("NO_COLOR") != null) enableColors = false;

		// Also respect Log.enableColor setting (synced from Log.__init__)
		// Note: Log.enableColor is set based on NO_COLOR env var in Log.__init__()
		// This provides a consistent color disable mechanism across the framework

		startTime = Sys.time();
		lastStepTime = startTime;
		currentStep = 0;
		totalSteps = steps != null ? steps : 0;
		#end
	}

	/**
	 * Print a section header
	 */
	public static function section(title:String):Void
	{
		var line = repeat("═", 60);
		println("");
		println(color(line, CYAN));
		println(color("  " + title, CYAN, BOLD));
		println(color(line, CYAN));
	}

	/**
	 * Print a step with progress
	 */
	public static function step(message:String):Void
	{
		currentStep++;
		var progress = totalSteps > 0 ? '[$currentStep/$totalSteps] ' : '[$currentStep] ';
		#if sys
		var elapsed = formatTime(Sys.time() - lastStepTime);
		lastStepTime = Sys.time();
		#end

		println(color(progress, DIM) + color(ICON_BUILD, BLUE) + " " + message);
	}

	/**
	 * Print success message
	 */
	public static function success(message:String):Void
	{
		println(color(ICON_SUCCESS, GREEN) + " " + color(message, GREEN));
	}

	/**
	 * Print error message
	 */
	public static function error(message:String):Void
	{
		println(color(ICON_ERROR, RED) + " " + color(message, RED, BOLD));
	}

	/**
	 * Print warning message
	 */
	public static function warning(message:String):Void
	{
		println(color(ICON_WARNING, YELLOW) + " " + color(message, YELLOW));
	}

	/**
	 * Print info message
	 */
	public static function info(message:String):Void
	{
		println(color(ICON_INFO, CYAN) + " " + message);
	}

	/**
	 * Print verbose/debug message (dimmed)
	 */
	public static function verbose(message:String):Void
	{
		println(color("  → " + message, DIM));
	}

	/**
	 * Print compilation progress bar
	 */
	public static function progressBar(current:Int, total:Int, ?label:String):Void
	{
		var width = 40;
		var percent = total > 0 ? current / total : 0;
		var filled = Math.floor(percent * width);
		var empty = width - filled;

		var bar = "[" + repeat("█", filled) + repeat("░", empty) + "]";
		var percentStr = Math.floor(percent * 100) + "%";
		var info = label != null ? ' $label' : '';

		print("\r" + color(bar, CYAN) + " " + color(percentStr, BOLD) + " " + color('($current/$total)$info', DIM));

		if (current >= total)
		{
			println(""); // New line when complete
		}
	}

	/**
	 * Print build summary
	 */
	public static function summary(success:Bool, ?details:Map<String, String>):Void
	{
		println("");
		section(success ? "Build Complete" : "Build Failed");

		if (success)
		{
			println(color(ICON_SUCCESS + " SUCCESS", GREEN, BOLD) + " " + color(ICON_ROCKET, YELLOW));
		}
		else
		{
			println(color(ICON_ERROR + " FAILED", RED, BOLD));
		}

		#if sys
		var totalTime = Sys.time() - startTime;
		println("");
		println(color(ICON_TIME + " Total time: ", DIM) + color(formatTime(totalTime), WHITE, BOLD));
		#end

		if (details != null)
		{
			for (key in details.keys())
			{
				println(color("  • ", DIM) + key + ": " + color(details.get(key), WHITE, BOLD));
			}
		}

		println("");
	}

	/**
	 * Print a trace in pretty format
	 */
	public static function trace(message:String, ?file:String, ?line:Int):Void
	{
		var location = "";
		if (file != null)
		{
			location = color(" [" + file + (line != null ? ':$line' : '') + "]", DIM);
		}
		println(color("TRACE:", MAGENTA, BOLD) + " " + message + location);
	}

	/**
	 * Print a box around text
	 */
	public static function box(text:String, ?title:String):Void
	{
		var lines = text.split("\n");
		var maxWidth = 0;

		if (title != null && title.length > maxWidth) maxWidth = title.length;
		for (line in lines)
		{
			if (line.length > maxWidth) maxWidth = line.length;
		}

		var topLine = title != null ? '┌─ $title ' + repeat("─", maxWidth - title.length + 1) + "┐"
									 : "┌" + repeat("─", maxWidth + 2) + "┐";

		println(color(topLine, CYAN));
		for (line in lines)
		{
			var padding = repeat(" ", maxWidth - line.length);
			println(color("│ ", CYAN) + line + padding + color(" │", CYAN));
		}
		println(color("└" + repeat("─", maxWidth + 2) + "┘", CYAN));
	}

	// Helper functions

	private static function repeat(str:String, count:Int):String
	{
		if (count <= 0) return "";
		var result = "";
		for (i in 0...count) result += str;
		return result;
	}

	private static function color(text:String, ?color:String, ?modifier:String):String
	{
		if (!enableColors) return text;

		var code = "";
		if (modifier != null) code += modifier;
		if (color != null) code += color;

		return code != "" ? code + text + RESET : text;
	}

	public static function formatTime(seconds:Float):String
	{
		if (seconds < 1) return Math.round(seconds * 1000) + "ms";
		if (seconds < 60) return Math.round(seconds * 10) / 10 + "s";

		var mins = Math.floor(seconds / 60);
		var secs = Math.floor(seconds % 60);
		return mins + "m " + secs + "s";
	}

	private static inline function print(text:String):Void
	{
		#if sys
		Sys.print(text);
		#else
		trace(text);
		#end
	}

	private static inline function println(text:String):Void
	{
		#if sys
		Sys.println(text);
		#else
		trace(text);
		#end
	}
}
