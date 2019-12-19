package edu.cornell.mannlib.vitro.webapp.filestorage.serving;

import static javax.servlet.http.HttpServletResponse.SC_OK;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileInputStream;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.UnavailableException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import edu.cornell.mannlib.vitro.webapp.config.ConfigurationProperties;
import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.modules.fileStorage.FileStorage;
import edu.cornell.mannlib.vitro.webapp.filestorage.impl.FileStorageImpl;
import edu.cornell.mannlib.vitro.webapp.filestorage.impl.FileStorageImplWrapper;
import edu.cornell.mannlib.vitro.webapp.filestorage.model.FileInfo;

public class ImageServingServlet extends FileServingServlet {
	/** If we can't locate the requested image, use this one instead. */
	private static final String PATH_MISSING_LINK_IMAGE = "/images/missingLink.png";
	public static final String DEFAULT_IMAGE_PATH = "harvesteredImage";

	private static final Log log = LogFactory.getLog(ImageServingServlet.class);

	private File rootDir;

        @Override
        public void init() throws ServletException {
                log.debug( "init called on ImageServingServlet" );
                super.init();
                log.debug( "init completed" );
        }
	
	@Override
	protected void doGet(HttpServletRequest rawRequest,
			HttpServletResponse response) throws ServletException, IOException {
		VitroRequest request = new VitroRequest(rawRequest);
		
		// Use the alias URL to get the URI of the bytestream object.
		String path = request.getServletPath() + request.getPathInfo();
		log.debug("Path is '" + path + "'");

		/*
		 * Get the mime type and an InputStream from the file. If we can't, use
		 * the dummy image file instead.
		 */
		InputStream in;
		String mimeType = "image/";
		try {
			if(path.indexOf(".") > 0){
				mimeType = mimeType + path.substring(path.lastIndexOf(".")+1, path.length());
			}
			in = openImageInputStream(path);
		} catch (Exception e) {
			log.warn("Failed to serve the file at '" + path + "' -- " + e);
			in = openMissingLinkImage(request);
			mimeType = "image/png";
		}
		response.setStatus(SC_OK);

		if (mimeType != null) {
			response.setContentType(mimeType);
		}

		ServletOutputStream out = null;
		try {
			out = response.getOutputStream();
			byte[] buffer = new byte[8192];
			int howMany;
			while (-1 != (howMany = in.read(buffer))) {
				out.write(buffer, 0, howMany);
			}
		} catch( Exception e ) {

			log.error("ERROR: couldn't stream file");
		} finally {
			try {
				in.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
			if (out != null) {
				try {
					out.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}
	
	/** Any suprises when opening the image? Use this one instead. */
	private InputStream openMissingLinkImage(VitroRequest vreq)
			throws FileNotFoundException {
		InputStream stream = vreq.getSession().getServletContext()
				.getResourceAsStream(PATH_MISSING_LINK_IMAGE);
		if (stream == null) {
			throw new FileNotFoundException("No image file at '"
					+ PATH_MISSING_LINK_IMAGE + "'");
		}
		return stream;
	}
	
	private InputStream openImageInputStream(String filePath) throws IOException {
		log.debug("openImageInputStream called" );
		if( fileStorage instanceof FileStorageImplWrapper ) {
			//return fileStorage.getImageStream(filePath);
			rootDir =  new File( "/usr/local/vivo/home/uploads/file_storage_root" );
			log.debug("cleaned path value: " + cleanFilePath(filePath));

                	File file = new File(rootDir, cleanFilePath(filePath));
                	
			if (!file.exists()) {
                        	throw new FileNotFoundException("No file exists with absolute path '" + file + "'");
                	}
			log.debug("Found file, so presumably everything is now okay.");
                	return new FileInputStream(file);
		}
		log.debug("nothing to return");
		return null;
	}

        private String cleanFilePath(String filePath){
                String fileName = null;
                String path = null;
                if(StringUtils.trimToNull(filePath) != null){
                        fileName = filePath.substring(filePath.lastIndexOf('/'));
                        path = filePath.replace(fileName, "").replace(".", "");
                }
                return new StringBuffer(StringUtils.trimToEmpty(path)).append(StringUtils.trimToEmpty(fileName) ).toString();
        }
	
	/**
	 * A POST request is treated the same as a GET request.
	 */
	@Override
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
}
