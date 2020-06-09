/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name
FROM `Facilities`
WHERE `membercost` >0
LIMIT 0 , 30

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT( name )
FROM `Facilities`
WHERE `membercost` =0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT `facid`, `name`, `membercost`,`monthlymaintenance` FROM Facilities WHERE membercost<.2*`monthlymaintenance`

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
FROM `Facilities`
WHERE `facid`
IN ( 1, 5 )
LIMIT 0 , 30

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT `name`, `monthlymaintenance` FROM `Facilities` 
CASE WHEN `monthlymaintenance`>100 THEN 'Expensive'
ELSE 'Cheap' END AS Expense
SELECT `name` , `monthlymaintenance` ,
CASE WHEN `monthlymaintenance` >100
THEN 'expensive'
ELSE 'cheap'
END AS 'Expense'
FROM `Facilities`
LIMIT 0 , 30


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT `surname` , `firstname` , MAX( `joindate` )
FROM `Members`
WHERE `memid`!=0
/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT( `firstname` , ' ', `surname` ) AS `Member Name` , `Facilities`.`name`
FROM `Members`
INNER JOIN `Bookings` ON `Members`.`memid` = `Bookings`.`memid`
INNER JOIN `Facilities` ON `Facilities`.`facid` = `Bookings`.`facid`
GROUP BY `name`
LIMIT 0 , 30


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


SELECT `name` , CONCAT( `firstname` , ' ', `surname` ) AS `Member Name` , (
`membercost` + `guestcost`
) AS `cost`
FROM `Facilities`
INNER JOIN `Bookings` ON `Facilities`.`facid` = `Bookings`.`facid`
INNER JOIN `Members` ON `Bookings`.`memid` = `Members`.`memid`
WHERE `Bookings`.`starttime` >= '2012-09-14'
AND `Bookings`.`starttime` < '2012-09-15'
AND (
`membercost` + `guestcost`
) >30
ORDER BY `cost` DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT `name` , (
`membercost` + `guestcost`
) AS `cost` , (

SELECT CONCAT( `firstname` , ' ', `surname` ) AS `Member Name`
)
FROM `Facilities`
INNER JOIN `Bookings` ON `Facilities`.`facid` = `Bookings`.`facid`
INNER JOIN `Members` ON `Bookings`.`memid` = `Members`.`memid`
WHERE `Bookings`.`starttime` >= '2012-09-14'
AND `Bookings`.`starttime` < '2012-09-15'
AND (
`member
ORDER BY `cost` DESC

/* PART 2: SQLite
d
Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
cur = conn.cursor()
query1 = 'SELECT name , revenue FROM (SELECT Facilities.name , SUM( CASE WHEN memid =0 THEN slots * Facilities.guestcost ELSE slots * membercost END ) AS revenue FROM Bookings INNER JOIN Facilities ON Bookings.facid = Facilities.facid GROUP BY Facilities.name) AS agg WHERE revenue <1000 ORDER BY revenue'
cur.execute(query1)
 
rows = cur.fetchall()
 
pd.DataFrame(rows)
/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
cur = conn.cursor()
query2 = """SELECT m.firstname || ' ' || m.surname as Recommended_By,
rcmd.firstname || ' ' || rcmd.surname as Member
FROM Members m
inner join Members rcmd on rcmd.recommendedby = m.memid
WHERE m.memid > 0 
order by m.surname,m.firstname, rcmd.surname,rcmd.firstname"""
cur.execute(query2)
 
rows = cur.fetchall()
 
pd.DataFrame(rows)

/* Q12: Find the facilities with their usage by member, but not guests */
query3 = """SELECT DISTINCT name,Members.surname, Members.firstname, COUNT (*) AS usage 
FROM Members INNER JOIN Bookings
ON Members.memid=Bookings.memid
INNER JOIN Facilities
ON Facilities.facid = Bookings.facid
WHERE Bookings.memid>0
GROUP BY Facilities.name, Members.surname, Members.firstname"""
cur.execute(query3)
 
rows = cur.fetchall()
 
 
pd.DataFrame(rows)

/* Q13: Find the facilities usage by month, but not guests */
cur = conn.cursor()
query4 = """SELECT DISTINCT name , CASE WHEN strftime('%m', starttime)='07' THEN 'July' WHEN strftime('%m', starttime)='08' THEN 'August' ELSE 'September' END as Month, COUNT (*) AS usage 
FROM Facilities INNER JOIN Bookings 
ON Facilities.facid = Bookings.facid
WHERE memid>0
GROUP BY Facilities.name, Month"""
cur.execute(query4)
 
rows = cur.fetchall()
 
 
pd.DataFrame(rows)
