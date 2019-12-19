package edu.ucsf.vitro.opensocial;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import javax.sql.DataSource;

public class GadgetSpec {
	private int appId = 0;
	private String name;
	private String openSocialGadgetURL;
	private List<String> channels = new ArrayList<String>();
	private Map<String, GadgetViewRequirements> viewRequirements = new HashMap<String, GadgetViewRequirements>();
	boolean enabled;
	private boolean unknownGadget = false;
	private static final Log log = LogFactory.getLog(GadgetSpec.class);


	public GadgetSpec(int appId, String name, String openSocialGadgetURL,
			List<String> channels, DataSource ds, boolean enabled, boolean unknownGadget)
			throws SQLException {
		this.appId = appId;
		this.name = name;
		this.openSocialGadgetURL = openSocialGadgetURL;
		this.channels.addAll(channels);
		this.enabled = enabled;
		this.unknownGadget = unknownGadget;

		// Load gadgets from the DB first
		if (!unknownGadget) {
			Connection conn = null;
			Statement stmt = null;
			ResultSet rset = null;

			try {
				String sqlCommand = "select page, viewer_req, owner_req, view, chromeId, opt_params, display_order from orng_app_views where appId = "
						+ appId;
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rset = stmt.executeQuery(sqlCommand);
				while (rset.next()) {
					viewRequirements.put(
							rset.getString(1),
							new GadgetViewRequirements(rset.getString(1), rset
									.getString(2), rset.getString(3), rset
									.getString(4), rset.getString(5), rset
									.getString(6), rset.getInt(7)));
				}
			} finally {
				try {
					rset.close();
				} catch (Exception e) {
				}
				try {
					stmt.close();
				} catch (Exception e) {
				}
				try {
					conn.close();
				} catch (Exception e) {
					log.error("Failed to close connection.");
				}
			}
		}
	}

	public int getAppId() {
		return appId;
	}

	public String getName() {
		return name;
	}

	public String getGadgetURL() {
		return openSocialGadgetURL;
	}

	public List<String> getChannels() {
		return channels;
	}

	public boolean listensTo(String channel) { // if an unknownd gadget just say yes,
												// we don't care about
												// performance in this situation
		return unknownGadget || channels.contains(channel);
	}

	public GadgetViewRequirements getGadgetViewRequirements(String page) {
		if (viewRequirements.containsKey(page)) {
			return viewRequirements.get(page);
		}
		return null;
	}

	public boolean show(String viewerId, String ownerId, String page,
			DataSource ds) throws SQLException {
		boolean show = true;
		// if there are no view requirements, go ahead and show it. We are
		// likely testing out a new gadget
		// if there are some, turn it off unless this page is
		if (viewRequirements.size() > 0) {
			show = false;
		}

		if (viewRequirements.containsKey(page)) {
			show = true;
			GadgetViewRequirements req = getGadgetViewRequirements(page);
			if ('U' == req.getViewerReq() && viewerId == null) {
				show = false;
			} else if ('R' == req.getViewerReq()) {
				show &= isRegisteredTo(viewerId, ds);
			}
			if ('R' == req.getOwnerReq()) {
				show &= isRegisteredTo(ownerId, ds);
			} else if ('S' == req.getOwnerReq()) {
				show &= (viewerId == ownerId);
			}
		}
		return show;
	}

	public boolean isRegisteredTo(String personId, DataSource ds)
			throws SQLException {
		int count = 0;

		Connection conn = null;
		PreparedStatement stmt = null;
		ResultSet rset = null;

		try {
			String sqlCommand = "select count(*) from orng_app_registry where appId = ? and personId = ?";

			conn = ds.getConnection();
			stmt = conn.prepareStatement(sqlCommand);
			stmt.setInt(1, getAppId());
			stmt.setString(2, personId);

			rset = stmt.executeQuery();
			while (rset.next()) {
				count = rset.getInt(1);
			}
		} finally {
			try {
				rset.close();
			} catch (Exception e) {
			}
			try {
				stmt.close();
			} catch (Exception e) {
			}
			try {
				conn.close();
			} catch (Exception e) {
				log.error("Failed to close connection.");
			}
		}

		return (count == 1);
	}

	public boolean fromSandbox() {
		return unknownGadget;
	}

	public boolean isEnabled() {
		return enabled;
	}
	
	// who sees it? Return the viewerReq for the ProfileDetails page
	public char getVisibleScope() {
		GadgetViewRequirements req = getGadgetViewRequirements("/display");
		return req != null ? req.getViewerReq() : ' ';
	}
	
	public String toString() {
		return "" + this.appId + ":" + this.name + ":" + this.openSocialGadgetURL;
	}

}
