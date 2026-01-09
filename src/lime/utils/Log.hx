package lime.utils;

import haxe.PosInfos;
import lime.utils.PrettyOutput;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class Log
{
	public static var level:LogLevel;
	public static var throwErrors:Bool = true;
	public static var usePrettyOutput:Bool = true;

	public static function debug(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.DEBUG)
		{
			#if js
			untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").debug("[" + info.className + "] " + message);
			#else
			println("[" + info.className + "] " + Std.string(message));
			#end
		}
	}

	public static function error(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.ERROR)
		{
			var messageStr = Std.string(message);

			if (throwErrors)
			{
				#if webassembly
				if (usePrettyOutput)
				{
					PrettyOutput.error(messageStr);
				}
				else
				{
					println("[" + info.className + "] ERROR: " + messageStr);
				}
				#end
				throw "[" + info.className + "] ERROR: " + messageStr;
			}
			else
			{
				#if js
				untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").error("[" + info.className + "] ERROR: " + messageStr);
				#else
				if (usePrettyOutput)
				{
					PrettyOutput.error(messageStr);
				}
				else
				{
					println("[" + info.className + "] ERROR: " + messageStr);
				}
				#end
			}
		}
	}

	public static function info(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.INFO)
		{
			#if js
			untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").info("[" + info.className + "] " + message);
			#else
			if (usePrettyOutput)
			{
				PrettyOutput.info(Std.string(message));
			}
			else
			{
				println("[" + info.className + "] " + Std.string(message));
			}
			#end
		}
	}

	public static inline function print(message:Dynamic):Void
	{
		#if sys
		Sys.print(Std.string(message));
		#elseif flash
		untyped __global__["trace"](Std.string(message));
		#elseif js
		untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").log(message);
		#else
		trace(message);
		#end
	}

	public static inline function println(message:Dynamic):Void
	{
		#if sys
		Sys.println(Std.string(message));
		#elseif flash
		untyped __global__["trace"](Std.string(message));
		#elseif js
		untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").log(message);
		#else
		trace(Std.string(message));
		#end
	}

	public static function verbose(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.VERBOSE)
		{
			if (usePrettyOutput)
			{
				PrettyOutput.verbose(Std.string(message));
			}
			else
			{
				println("[" + info.className + "] " + message);
			}
		}
	}

	public static function warn(message:Dynamic, ?info:PosInfos):Void
	{
		if (level >= LogLevel.WARN)
		{
			#if js
			untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").warn("[" + info.className + "] WARNING: " + message);
			#else
			if (usePrettyOutput)
			{
				PrettyOutput.warning(Std.string(message));
			}
			else
			{
				println("[" + info.className + "] WARNING: " + Std.string(message));
			}
			#end
		}
	}

	// Build-specific pretty output helpers

	/**
	 * Initialize build output (shows header)
	 */
	public static function buildStart(?steps:Int):Void
	{
		#if sys
		if (usePrettyOutput)
		{
			PrettyOutput.init(steps);
			PrettyOutput.section("Lime Build System");
		}
		#end
	}

	/**
	 * Print a build section header
	 */
	public static function buildSection(title:String):Void
	{
		#if sys
		if (usePrettyOutput)
		{
			PrettyOutput.section(title);
		}
		else
		{
			println("");
			println("=== " + title + " ===");
		}
		#end
	}

	/**
	 * Print a build step with progress
	 */
	public static function buildStep(message:String):Void
	{
		#if sys
		if (usePrettyOutput)
		{
			PrettyOutput.step(message);
		}
		else
		{
			println("→ " + message);
		}
		#end
	}

	/**
	 * Print a success message
	 */
	public static function buildSuccess(message:String):Void
	{
		#if sys
		if (usePrettyOutput)
		{
			PrettyOutput.success(message);
		}
		else
		{
			println("✓ " + message);
		}
		#end
	}

	/**
	 * Print build summary
	 */
	public static function buildSummary(success:Bool, ?details:Map<String, String>):Void
	{
		#if sys
		if (usePrettyOutput)
		{
			PrettyOutput.summary(success, details);
		}
		else
		{
			println("");
			println(success ? "Build Complete!" : "Build Failed!");
		}
		#end
	}

	/**
	 * Print a progress bar
	 */
	public static function buildProgress(current:Int, total:Int, ?label:String):Void
	{
		#if sys
		if (usePrettyOutput)
		{
			PrettyOutput.progressBar(current, total, label);
		}
		#end
	}

	private static function __init__():Void
	{
		#if no_traces
		level = NONE;
		#elseif verbose
		level = VERBOSE;
		#else
		#if sys
		var args = Sys.args();
		if (args.indexOf("-v") > -1 || args.indexOf("-verbose") > -1)
		{
			level = VERBOSE;
		}
		else
		#end
		{
			#if debug
			level = DEBUG;
			#else
			level = INFO;
			#end
		}
		#end

		// Check if pretty output should be disabled
		#if sys
		if (Sys.getEnv("NO_COLOR") != null || Sys.getEnv("LIME_NO_PRETTY") != null)
		{
			usePrettyOutput = false;
		}
		#end

		#if js
		if (untyped #if haxe4 js.Syntax.code #else __js__ #end ("typeof console") == "undefined")
		{
			untyped #if haxe4 js.Syntax.code #else __js__ #end ("console = {}");
		}
		if (untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").log == null)
		{
			untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").log = function() {};
		}
		#end
	}
}
