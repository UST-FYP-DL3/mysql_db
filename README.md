# mysql_db

This chapter will only introduce the relationships, dependences and examples of using the application+user database.

# First table: USER_FULLINFO (contains the full details of an user of our FYP application)
userid is set to primary key and email is set to be unique value. This is the parent table since there is no foreign key constraint.

CREATE TABLE USER_FULLINFO (
   userid VARCHAR(20) NOT NULL,
   username VARCHAR(20) NOT NULL,
   user_password VARCHAR(40) NOT NULL,
   risk_acceptance_level DOUBLE DEFAULT 0,
   monthly_expense DOUBLE DEFAULT 0,
   total_asset DOUBLE DEFAULT 0,
   principal DOUBLE DEFAULT 0,
   cash DOUBLE DEFAULT 0,
   monthly_income DOUBLE DEFAULT NULL,
   first_invest_day VARCHAR(20) NOT NULL,
   email VARCHAR(40) NOT NULL,
   sex VARCHAR(10) NOT NULL,
   age DOUBLE DEFAULT NULL,
   PRIMARY KEY (userid),
   UNIQUE (email)
);

Add dummy data values into the USER_FULLINFO table
Two users are added, one is Eric, another one is Mary
INSERT INTO `USER_FULLINFO` VALUES ('123456789', 'Eric','ilovehkust',1,2000,31100,28815,100,3000, '01/01/2020','cymaae@connect.ust.hk','M',20);
INSERT INTO `USER_FULLINFO` VALUES ('324565944', 'Mary','ihatehkust',2,1000,1800,1400,300,300, '01/03/2020','mary@connect.ust.hk','F',19);
Now the current table looks like:

# Second table: USER_INFO (contains only brief information of an user, e.g. userid, portfolio_id (the portfolio owned by the user), and portfolio_quantity (an user may have more than 1 portfolio))
userid and portfolio_id are the joint primary key in this table. Foreign key is userid, that means the userid in USER_INFO table will reference to the userid in USER_FULLINFO table. This is the child table of USER_FULLINFO as the foreign key constraint is set to USER_FULLINFO.

CREATE TABLE USER_INFO (
   userid VARCHAR(20) NOT NULL,
   portfolio_id VARCHAR(20) NOT NULL,
   portfolio_quantity INT DEFAULT 0,
   PRIMARY KEY (userid , portfolio_id),
   FOREIGN KEY (userid)
   REFERENCES USER_FULLINFO (userid)
      ON DELETE CASCADE ON UPDATE CASCADE
);


// Add dummy data values into the USER_INFO table
// userid = 123456789 has two portfolios (portfolio_quantity = 2), where the portfolio_id are 234567891 and 981542267 respectively.
// Look back to the USER_INFO, the username of userid = 123456789 is Eric
INSERT INTO `USER_INFO` VALUES ('123456789', '234567891',2);
INSERT INTO `USER_INFO` VALUES ('123456789', '981542267',2);
INSERT INTO `USER_INFO` VALUES ('324565944', '785112123',1);

Example 1: get the user full details by using userid from USER_INFO table
This query 
SELECT USER_INFO.userid, USER_INFO.portfolio_id, 
USER_FULLINFO.username, USER_FULLINFO.total_asset, USER_FULLINFO.cash, USER_FULLINFO.email
FROM USER_INFO
LEFT JOIN USER_FULLINFO ON USER_INFO.userid = USER_FULLINFO.userid;
