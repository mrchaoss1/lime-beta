package lime.utils;

import haxe.io.Bytes;
import sys.io.File;
import sys.FileSystem;

/**
 * NDLL encryption/decryption utilities for protecting lime.ndll
 * while maintaining compatibility with other dynamic NDLLs
 */
class NDLLProtection
{
	// XOR encryption key - change this to your own secret key!
	private static inline var ENCRYPTION_KEY:String = "YourSecretKey_Change_This_2024";

	// Marker bytes to identify encrypted files
	private static inline var MAGIC_HEADER:String = "LIME_ENC";

	/**
	 * Encrypt an NDLL file (use at build time)
	 * @param sourcePath Path to original .ndll file
	 * @param destPath Path to save encrypted file
	 */
	public static function encryptNDLL(sourcePath:String, destPath:String):Void
	{
		if (!FileSystem.exists(sourcePath))
		{
			throw "Source NDLL not found: " + sourcePath;
		}

		var sourceBytes = File.getBytes(sourcePath);
		var encrypted = encrypt(sourceBytes, ENCRYPTION_KEY);

		// Add magic header
		var output = Bytes.alloc(MAGIC_HEADER.length + encrypted.length);
		output.blit(0, Bytes.ofString(MAGIC_HEADER), 0, MAGIC_HEADER.length);
		output.blit(MAGIC_HEADER.length, encrypted, 0, encrypted.length);

		File.saveBytes(destPath, output);
		trace("Encrypted NDLL saved to: " + destPath);
		trace("Original size: " + sourceBytes.length + " bytes");
		trace("Encrypted size: " + output.length + " bytes");
	}

	/**
	 * Decrypt an NDLL file (use at runtime)
	 * @param encryptedPath Path to encrypted file
	 * @param tempPath Path to save decrypted file temporarily
	 * @return Path to decrypted file
	 */
	public static function decryptNDLL(encryptedPath:String, tempPath:String):String
	{
		if (!FileSystem.exists(encryptedPath))
		{
			throw "Encrypted NDLL not found: " + encryptedPath;
		}

		var encryptedBytes = File.getBytes(encryptedPath);

		// Verify magic header
		var header = encryptedBytes.sub(0, MAGIC_HEADER.length).toString();
		if (header != MAGIC_HEADER)
		{
			throw "Invalid encrypted NDLL file (bad magic header)";
		}

		// Extract encrypted data (skip header)
		var encrypted = encryptedBytes.sub(MAGIC_HEADER.length, encryptedBytes.length - MAGIC_HEADER.length);

		// Decrypt
		var decrypted = decrypt(encrypted, ENCRYPTION_KEY);

		// Save to temp location
		File.saveBytes(tempPath, decrypted);

		return tempPath;
	}

	/**
	 * Check if a file is encrypted
	 */
	public static function isEncrypted(path:String):Bool
	{
		if (!FileSystem.exists(path)) return false;

		var bytes = File.getBytes(path);
		if (bytes.length < MAGIC_HEADER.length) return false;

		var header = bytes.sub(0, MAGIC_HEADER.length).toString();
		return header == MAGIC_HEADER;
	}

	/**
	 * XOR encryption (simple but effective)
	 */
	private static function encrypt(data:Bytes, key:String):Bytes
	{
		var keyBytes = Bytes.ofString(key);
		var result = Bytes.alloc(data.length);

		for (i in 0...data.length)
		{
			result.set(i, data.get(i) ^ keyBytes.get(i % keyBytes.length));
		}

		return result;
	}

	/**
	 * XOR decryption (same as encryption for XOR)
	 */
	private static function decrypt(data:Bytes, key:String):Bytes
	{
		return encrypt(data, key); // XOR is symmetric
	}

	/**
	 * Generate a random temporary file path
	 */
	public static function getTempPath(baseName:String):String
	{
		#if windows
		var tempDir = Sys.getEnv("TEMP");
		if (tempDir == null) tempDir = Sys.getEnv("TMP");
		if (tempDir == null) tempDir = "C:\\Windows\\Temp";
		#else
		var tempDir = "/tmp";
		#end

		var randomId = Std.random(999999);
		var timestamp = Std.int(Date.now().getTime());
		return tempDir + "/" + baseName + "_" + timestamp + "_" + randomId + ".ndll";
	}

	/**
	 * Clean up temporary decrypted file
	 */
	public static function cleanupTemp(path:String):Void
	{
		if (FileSystem.exists(path))
		{
			try
			{
				FileSystem.deleteFile(path);
			}
			catch (e:Dynamic)
			{
				// Ignore cleanup errors
			}
		}
	}
}
