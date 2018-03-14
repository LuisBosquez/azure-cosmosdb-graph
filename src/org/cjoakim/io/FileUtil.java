package org.cjoakim.io;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Vector;

/**
 * This class contains common logic for File checking and processing.
 *
 * @author Chris Joakim, Microsoft
 * @version 2018/03/13
 */
public class FileUtil {

	/**
	 * Default constructor method
	 */
	public FileUtil() {

		super();
	}

	public boolean isReadableFile(String filename) {

		if (filename != null) {
			File file = new File(filename);
			if (file.exists() && file.canRead() && file.isFile()) {
				return true;
			}
		}
		return false;
	}

	public boolean isDirectory(String filename) {

		if (filename != null) {
			File file = new File(filename);
			if (file.exists() && file.canRead() && file.isDirectory()) {
				return true;
			}
		}
		return false;
	}

	public String[] readFileAsLines(String filename) throws Exception {

		File file = null;
		FileReader fileReader = null;
		BufferedReader buffReader = null;
		boolean continueToRead = true;
		Vector<String> vector = new Vector<String>();
		String[] array = null;

		try {
			// Use a BufferedReader so as to use the 'readLine()' method.
			file = new File(filename);
			fileReader = new FileReader(file);
			buffReader = new BufferedReader(fileReader);

			while (continueToRead) {
				String lineRead = buffReader.readLine();
				if (lineRead == null) {
					continueToRead = false;
				} else {
					vector.addElement(lineRead);
				}
			}
			array = new String[vector.size()];
			vector.copyInto(array);
		}
		catch (Exception ex) {
			throw ex;
		}
		finally {
			if (fileReader != null) {
				try {
					fileReader.close();
				}
				catch (IOException ex) {
					// do nothing; we tried our best
				}
			}
		}
		return array;
	}

	public boolean canRead(String filename) {

		if (filename != null) {
			File file = new File(filename);
			if (file.exists() && file.canRead() && file.isFile()) {
				return true;
			}
		}
		return false;
	}

}
