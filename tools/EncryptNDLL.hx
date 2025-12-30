import lime.utils.NDLLProtection;
import sys.io.File;
import sys.FileSystem;

/**
 * Command-line tool to encrypt lime.ndll files
 *
 * Usage:
 *   haxe --run tools.EncryptNDLL <ndll-path>
 *
 * Example:
 *   haxe --run tools.EncryptNDLL ndll/Linux64/lime.ndll
 */
class EncryptNDLL
{
	static function main()
	{
		var args = Sys.args();

		if (args.length == 0)
		{
			printUsage();
			Sys.exit(1);
		}

		var sourcePath = args[0];

		// Handle both single file and directory
		if (FileSystem.isDirectory(sourcePath))
		{
			encryptDirectory(sourcePath);
		}
		else
		{
			encryptFile(sourcePath);
		}

		Sys.println("\n✅ Encryption complete!");
	}

	static function encryptFile(sourcePath:String):Void
	{
		if (!FileSystem.exists(sourcePath))
		{
			Sys.println("❌ Error: File not found: " + sourcePath);
			Sys.exit(1);
		}

		Sys.println("🔐 Encrypting: " + sourcePath);

		var destPath = sourcePath + ".encrypted";

		try
		{
			NDLLProtection.encryptNDLL(sourcePath, destPath);

			// Optionally delete original
			if (Sys.getEnv("DELETE_ORIGINAL") == "1")
			{
				FileSystem.deleteFile(sourcePath);
				Sys.println("   Deleted original file");
			}

			Sys.println("   ✓ Encrypted to: " + destPath);
		}
		catch (e:Dynamic)
		{
			Sys.println("   ❌ Encryption failed: " + e);
			Sys.exit(1);
		}
	}

	static function encryptDirectory(dirPath:String):Void
	{
		Sys.println("🔐 Encrypting all .ndll files in: " + dirPath);

		var count = 0;

		for (entry in FileSystem.readDirectory(dirPath))
		{
			var fullPath = dirPath + "/" + entry;

			if (FileSystem.isDirectory(fullPath))
			{
				encryptDirectory(fullPath); // Recursive
			}
			else if (entry.indexOf("lime") >= 0 && (entry.endsWith(".ndll") || entry.endsWith(".so") || entry.endsWith(".dll")))
			{
				encryptFile(fullPath);
				count++;
			}
		}

		if (count > 0)
		{
			Sys.println("   Encrypted " + count + " file(s) in " + dirPath);
		}
	}

	static function printUsage():Void
	{
		Sys.println("╔════════════════════════════════════════════════════════════╗");
		Sys.println("║          Lime NDLL Encryption Tool                       ║");
		Sys.println("╚════════════════════════════════════════════════════════════╝");
		Sys.println("");
		Sys.println("Usage:");
		Sys.println("  haxe -cp src --run EncryptNDLL <path>");
		Sys.println("");
		Sys.println("Arguments:");
		Sys.println("  <path>  Path to .ndll file or directory containing .ndll files");
		Sys.println("");
		Sys.println("Examples:");
		Sys.println("  # Encrypt single file");
		Sys.println("  haxe -cp src --run EncryptNDLL ndll/Linux64/lime.ndll");
		Sys.println("");
		Sys.println("  # Encrypt all NDLLs in directory");
		Sys.println("  haxe -cp src --run EncryptNDLL ndll/");
		Sys.println("");
		Sys.println("  # Delete original after encryption");
		Sys.println("  DELETE_ORIGINAL=1 haxe -cp src --run EncryptNDLL ndll/Linux64/lime.ndll");
		Sys.println("");
		Sys.println("Note:");
		Sys.println("  - Creates .encrypted files alongside originals");
		Sys.println("  - Only encrypts files with 'lime' in the name");
		Sys.println("  - Does NOT encrypt linc_luajit, hxvlc, or other third-party NDLLs");
		Sys.println("");
	}
}
