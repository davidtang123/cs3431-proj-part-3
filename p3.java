//CS3431 Project Part 3
//David Tang, John Pugmire

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Scanner;

public class p3 {
    static final String DB_DRIVER = "oracle.jdbc.driver.OracleDriver";
    static final String DB_URL = "jdbc:oracle:thin:@oracle.wpi.edu:1521:orcl";
    static Connection dbConnection = null;

    public static void initConnection(String username, String password)
        throws SQLException {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            System.out.println("could not load driver class " + DB_DRIVER);
            e.printStackTrace();
        }
        dbConnection = DriverManager.getConnection(DB_URL, username, password);
    }

    public static void printUsage() {
        System.out.println("USAGE: p3 USERNAME PASSWORD OPTION");
        System.out.println("Options: ");
        showOptions();
    }

    public static void showOptions() {
        System.out.println("1 - Report Health Provider Information");
        System.out.println("2 - Report Health Service Information");
        System.out.println("3 - Report Path Information");
        System.out.println("4 - Update Health Service Information");
    }

    public static void main(String[] args) {
        /* Argument processing */
        if (args.length < 2) {
            printUsage();
            return;
        } else if (args.length == 2) {
            showOptions();
            return;
        }

        String username = args[0], password = args[1];
        int option = 0;
        try {
            option = Integer.parseInt(args[2]);
        } catch (NumberFormatException e) {
            System.out.println("invalid option");
            showOptions();
            return;
        }

        if (option > 4 || option < 1) {
            System.out.println("invalid option");
            showOptions();
            return;
        }

        /* Connect to the database */
        try {
            initConnection(username, password);
        } catch (SQLException e) {
            System.out.println("Error connecting to database.");
            e.printStackTrace();
            return;
        }

        /* Dispatch based on the option */
        Scanner sc = new Scanner (System.in);

        switch (option) {
        case 1:
            System.out.print("Enter Provider ID: ");
            int id = sc.nextInt();
            try {
                showHPInfo(id);
            } catch (SQLException e) {
                System.out.println("Error fetching provider information.");
                e.printStackTrace();
                return;
            }
            break;
        case 2:
            System.out.print("Enter Health Service Name: ");
            String name = sc.nextLine();
            try {
                showHSInfo(name);
            } catch (SQLException e) {
                System.out.println("Error fetching service information.");
                e.printStackTrace();
                return;
            }
            break;
        case 3:
            System.out.print("Start Location: ");
            String start = sc.nextLine();
            System.out.print("End Location: ");
            String end = sc.nextLine();
            try {
                showPathInfo(start, end);
            } catch (SQLException e) {
                System.out.println("Error fetching path information.");
                e.printStackTrace();
                return;
            }
            break;
        case 4:
			System.out.print("Enter Health Service Name:");
			String sname = sc.nextLine();
			System.out.print("Enter the new LocationID:");
			String lid = sc.nextLine();
			try {
				updateHSInfo(sname, lid);
			} catch (SQLException e){
				System.out.println("Error updating health service information.");
				e.printStackTrace();
				return;
			}
            break;
        }
    }

    /* Solution for step 2 */
    public static void showHPInfo(int id) throws SQLException {
        PreparedStatement stmt;
        ResultSet rSet;
        boolean hasNext;

        String providerQuery = "SELECT * " +
            "FROM Provider " +
            "WHERE ProviderID = ?";
        stmt = dbConnection.prepareStatement(providerQuery);
        stmt.setInt(1, id);
        rSet = stmt.executeQuery();
        hasNext = rSet.next();

        if (!hasNext) {
            System.out.println("Provider not found.");
            return;
        }

        System.out.println("Health Provider Information");
        System.out.println("Provider ID: " + id);
        System.out.println("First Name: " + rSet.getNString("FirstName"));
        System.out.println("Last Name: " + rSet.getNString("LastName"));

        String titleQuery = "SELECT * " +
            "FROM ProviderTitle " +
            "WHERE ProviderID = ?";
        stmt = dbConnection.prepareStatement(titleQuery);
        stmt.setInt(1, id);
        rSet = stmt.executeQuery();

        System.out.print("Title: ");
        hasNext = rSet.next();
        if (hasNext) {
            System.out.print(rSet.getNString("Acronym"));
            hasNext = rSet.next();
        }
        while (hasNext) {
            System.out.print(", " + rSet.getNString("Acronym"));
            hasNext = rSet.next();
        }
        System.out.println();

        String locQuery = "SELECT * " +
            "FROM (Office NATURAL JOIN Location)" +
            "WHERE ProviderID = ?";
        stmt = dbConnection.prepareStatement(locQuery);
        stmt.setInt(1, id);
        rSet = stmt.executeQuery();

        System.out.print("Office Location: ");
        hasNext = rSet.next();
        if (hasNext) {
            System.out.print(rSet.getNString("LocationName"));
            hasNext = rSet.next();
        }
        while (hasNext) {
            System.out.print(", " + rSet.getNString("LocationName"));
            hasNext = rSet.next();
        }
        System.out.println();
    }

    /* Solution for step 3 */
    public static void showHSInfo(String name) throws SQLException {
        PreparedStatement stmt;
        ResultSet rSet;
        boolean hasNext;

        String serviceQuery = "SELECT * " +
            "FROM Services " +
            "WHERE ServiceName = ?";
        stmt = dbConnection.prepareStatement(serviceQuery);
        stmt.setString(1, name);
        rSet = stmt.executeQuery();
        hasNext = rSet.next();

        if (!hasNext) {
            System.out.println("Service not found.");
            return;
        }
        System.out.println("Health Service Information");
        System.out.println("Service Name: " + name);
        System.out.println("Health Type: " + rSet.getNString("HealthType"));

        String locQuery = "SELECT * " +
            "FROM (ResidesIn NATURAL JOIN Location)" +
            "WHERE ServiceName = ?";
        stmt = dbConnection.prepareStatement(locQuery);
        stmt.setString(1, name);
        rSet = stmt.executeQuery();
        hasNext = rSet.next();

        if (!hasNext) {
            System.out.println("Couldn't find service location.");
            return;
        }
        System.out.println("Location: " + rSet.getNString("LocationName"));
        System.out.println("Floor: " + rSet.getNString("FloorID"));
    }

    /* Solution for step 4 */
    public static void showPathInfo(String startName, String endName)
        throws SQLException {
        PreparedStatement stmt;
        ResultSet rSet;
        boolean hasNext;

        String startID, endID;

        String locQuery = "SELECT * " +
            "FROM Location " +
            "WHERE LocationName = ?";
        stmt = dbConnection.prepareStatement(locQuery);
        stmt.setString(1, startName);
        rSet = stmt.executeQuery();
        hasNext = rSet.next();
        if (!hasNext) {
            System.out.println("Couldn't find start location.");
            return;
        }
        startID = rSet.getNString("LocationID");

        stmt.setString(1, endName);
        rSet = stmt.executeQuery();
        hasNext = rSet.next();
        if (!hasNext) {
            System.out.println("Couldn't find end location.");
            return;
        }
        endID = rSet.getNString("LocationID");

        int minPathLen, minPathID;
        String lenQuery = "SELECT PathID, COUNT(LocationID) " +
            "FROM (Path NATURAL JOIN PathContains) " +
            "WHERE PathStart = ?" +
            "AND PathEnd = ?" +
            "GROUP BY PathID";
        stmt = dbConnection.prepareStatement(lenQuery);
        stmt.setString(1, startName);
        stmt.setString(2, endName);
        rSet = stmt.executeQuery();
        hasNext = rSet.next();
        if (!hasNext) {
            System.out.println("No paths found.");
            return;
        }
        minPathLen = rSet.getInt(2);
        minPathID = rSet.getInt("PathID");
        hasNext = rSet.next();
        while(hasNext) {
            int l = rSet.getInt(2);
            int i = rSet.getInt("PathID");
            if (l < minPathLen) {
                minPathLen = l;
                minPathID = i;
            }
            hasNext = rSet.next();
        }

        System.out.println("Path ID for shortest path: " + minPathID);

        // Represents the data that we need to pull from PathContents
        class PathLoc implements Comparable<PathLoc> {
            int order;
            String name;
            String floor;
            public PathLoc(int o,String n,String f) {
                order = o;
                name = n;
                floor = f;
            }
            public int compareTo(PathLoc p2) {
                return new Integer(order).compareTo(p2.order);
            }
        };
        // Will hold all our locations in the path
        ArrayList<PathLoc> contents = new ArrayList<PathLoc>();

        String ctsQuery = "SELECT LocationName, PathOrder, FloorID " +
            "FROM (PathContains NATURAL JOIN Location) " +
            "WHERE PathID = ?";
        stmt = dbConnection.prepareStatement(ctsQuery);
        stmt.setInt(1, minPathID);
        rSet = stmt.executeQuery();
        hasNext = rSet.next();
        while (hasNext) {
            contents.add(new PathLoc(
                             rSet.getInt("PathOrder"),
                             rSet.getNString("LocationName"),
                             rSet.getNString("FloorID")));
            hasNext = rSet.next();
        }
        Collections.sort(contents);

        for(int i = 0; i < contents.size();++i) {
            System.out.printf("\t%-4d %-20s %-8s\n",
                              contents.get(i).order,
                              contents.get(i).name,
                              contents.get(i).floor);
        }
    }
	
	/*Solution for Step 5*/
	public static void updateHSInfo(String hsname, String lid) throws SQLException {
        Statement stmt = dbConnection.createStatement();
        PreparedStatement stmt;
		int count;

        String updatestring = "UPDATE ResidesIn " +
            "SET LocationID = '?' WHERE ServiceName = '?'";
		stmt = dbConnection.prepareStatement(updatestring);
		stmt.setString(1, lid);
		stmt.setSTring(2, hsname);
        count = stmt.executeUpdate(updatestring);
        
        if (count == 0) {
            System.out.println("Could not find health service.");
            return;
        }
        System.out.println();
    }
}
