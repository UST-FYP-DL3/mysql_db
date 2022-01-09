-- drop database application; //comment 
CREATE DATABASE application;
USE application;
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
-- dummy data
INSERT INTO `USER_FULLINFO` VALUES ('123456789', 'Eric','ilovehkust',1,2000,31100,28815,100,3000,
'01/01/2020','cymaae@connect.ust.hk','M',20);
INSERT INTO `USER_FULLINFO` VALUES ('324565944', 'Mary','ihatehkust',2,1000,1800,1400,300,300,
'01/03/2020','mary@connect.ust.hk','F',19);

CREATE TABLE USER_INFO (
    userid VARCHAR(20) NOT NULL,
    portfolio_id VARCHAR(20) NOT NULL,
    portfolio_quantity INT DEFAULT 0,
    PRIMARY KEY (userid , portfolio_id),
    FOREIGN KEY (userid)
        REFERENCES USER_FULLINFO (userid)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- dummy data
INSERT INTO `USER_INFO` VALUES ('123456789', '234567891',2);
INSERT INTO `USER_INFO` VALUES ('123456789', '981542267',2);
INSERT INTO `USER_INFO` VALUES ('324565944', '785112123',1);

-- example 1: get the user full details by using userid from USER_INFO table
-- remark: can create "View" to store this result
SELECT USER_INFO.userid, USER_INFO.portfolio_id, 
USER_FULLINFO.username, USER_FULLINFO.total_asset, USER_FULLINFO.cash, USER_FULLINFO.email
FROM USER_INFO
LEFT JOIN USER_FULLINFO ON USER_INFO.userid = USER_FULLINFO.userid;

CREATE TABLE TRANSACTION_HISTORY (
    userid VARCHAR(20) NOT NULL,
    portfolio_id VARCHAR(20) NOT NULL,
    stock VARCHAR(20) NOT NULL,
    begin_trade_time VARCHAR(20) NOT NULL,
    end_trade_time VARCHAR(20) DEFAULT NULL,
    buy_price DOUBLE NOT NULL,
    sell_price DOUBLE DEFAULT NULL,
    PRIMARY KEY (userid , portfolio_id , stock , begin_trade_time),
    FOREIGN KEY (userid , portfolio_id)
        REFERENCES USER_INFO (userid , portfolio_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- dummy data
INSERT INTO `TRANSACTION_HISTORY` VALUES('123456789','234567891','AAPL','5/6/2021',NULL,460,NULL);
INSERT INTO `TRANSACTION_HISTORY` VALUES('123456789','234567891','Goldman Sachs','2/3/2021',NULL,291.5,NULL);
INSERT INTO `TRANSACTION_HISTORY` VALUES('123456789','981542267','Google','8/10/2021',NULL,835,NULL);
INSERT INTO `TRANSACTION_HISTORY` VALUES('324565944','785112123','AWS','7/15/2021','8/14/2021',35,36.25);

-- example 2: get all the transaction records of user with userid = 123456789
SELECT *
FROM USER_INFO
INNER JOIN TRANSACTION_HISTORY ON 
USER_INFO.userid = TRANSACTION_HISTORY.userid
and USER_INFO.portfolio_id = TRANSACTION_HISTORY.portfolio_id
and USER_INFO.userid = '123456789';

CREATE TABLE FRIENDSHIP (
    userid VARCHAR(20) NOT NULL,
    has_friend BOOLEAN,
    friend_user_id VARCHAR(20) DEFAULT NULL,
    PRIMARY KEY (userid),
    FOREIGN KEY (userid)
        REFERENCES USER_INFO (userid),
    FOREIGN KEY (friend_user_id)
        REFERENCES USER_INFO (userid)
);

-- dummy data
INSERT INTO `FRIENDSHIP` VALUES ('123456789', true,'324565944');
INSERT INTO `FRIENDSHIP` VALUES ('324565944', true,'123456789');

-- example 3: get the friend id for each user
SELECT distinct USER_INFO.userid, FRIENDSHIP.friend_user_id
FROM USER_INFO
LEFT JOIN FRIENDSHIP ON 
USER_INFO.userid = FRIENDSHIP.userid;

CREATE TABLE PORTFOLIO (
    userid VARCHAR(20) NOT NULL,
    portfolio_id VARCHAR(20) NOT NULL,
    stock VARCHAR(20) NOT NULL,
    profit DOUBLE DEFAULT 0,
    return_rate DOUBLE DEFAULT 0,
    dividend_total DOUBLE DEFAULT 0,
    investment_horizon DOUBLE DEFAULT 0,
    stock_action VARCHAR(4) NOT NULL,
    num_of_share DOUBLE DEFAULT 0,
    total_balance DOUBLE DEFAULT 0,
    principal DOUBLE DEFAULT 0,
    PRIMARY KEY (portfolio_id , stock , stock_action),
    FOREIGN KEY (userid , portfolio_id)
        REFERENCES USER_INFO (userid , portfolio_id),
    FOREIGN KEY (userid , portfolio_id , stock)
        REFERENCES TRANSACTION_HISTORY (userid , portfolio_id , stock)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- dummy data
INSERT INTO `PORTFOLIO` VALUES('123456789','234567891','AAPL',500,8.6957,300,30,'buy',20,10000,9200);
INSERT INTO `PORTFOLIO` VALUES('123456789','234567891','Goldman Sachs',15,2.9160,70,30,'hold',10,3000,2915);
INSERT INTO `PORTFOLIO` VALUES('123456789','981542267','Google',800,7.78,500,30,'buy',20,18000,16700);
INSERT INTO `PORTFOLIO` VALUES('324565944','785112123','AWS',0,0,0,30,'buy',40,1500,1400);
INSERT INTO `PORTFOLIO` VALUES('324565944','785112123','AWS',50,7.1429,50,30,'sell',40,1500,1400);

-- example 4: get the portfolio details for each user and show the full details of users at the same time
SELECT USER_INFO.userid, USER_INFO.portfolio_id,
USER_FULLINFO.username, USER_FULLINFO.total_asset, USER_FULLINFO.email,
PORTFOLIO.stock, PORTFOLIO.profit, PORTFOLIO.dividend_total, PORTFOLIO.num_of_share,
PORTFOLIO.principal, PORTFOLIO.stock_action, PORTFOLIO.total_balance
FROM USER_INFO
LEFT JOIN PORTFOLIO ON USER_INFO.userid = PORTFOLIO.userid and USER_INFO.portfolio_id = PORTFOLIO.portfolio_id
LEFT JOIN USER_FULLINFO ON USER_INFO.userid = USER_FULLINFO.userid
where USER_INFO.userid = '123456789';

-- example 5: get the transaction history for each portfolio
SELECT PORTFOLIO.userid, PORTFOLIO.portfolio_id, PORTFOLIO.stock, PORTFOLIO.stock_action,
TRANSACTION_HISTORY.begin_trade_time, TRANSACTION_HISTORY.end_trade_time, 
TRANSACTION_HISTORY.buy_price, TRANSACTION_HISTORY.sell_price
FROM PORTFOLIO
LEFT JOIN TRANSACTION_HISTORY ON 
PORTFOLIO.userid = TRANSACTION_HISTORY.userid
and PORTFOLIO.portfolio_id = TRANSACTION_HISTORY.portfolio_id
and PORTFOLIO.stock = TRANSACTION_HISTORY.stock;


CREATE TABLE STOCK (
    dates VARCHAR(20) NOT NULL,
    portfolio_id VARCHAR(20) NOT NULL,
    stock VARCHAR(20) NOT NULL,
    industry VARCHAR(40) NOT NULL,
    current_price DOUBLE NOT NULL,
    dividend_per_share DOUBLE DEFAULT 0,
    volatility DOUBLE,
    volume DOUBLE DEFAULT 0,
    PX_OPEN DOUBLE,
    PX_HIGH DOUBLE,
    PX_LOW DOUBLE,
    PX_CLOSE DOUBLE,
    stock_action VARCHAR(4) NOT NULL,
    PRIMARY KEY (dates , stock , portfolio_id , stock_action),
    FOREIGN KEY (portfolio_id , stock , stock_action)
        REFERENCES PORTFOLIO (portfolio_id , stock , stock_action)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- dummy data
INSERT INTO `STOCK` VALUES('5/6/2021','234567891','AAPL','technology',460,15,3.6,5000000,460,480,445,463,'buy');
INSERT INTO `STOCK` VALUES('2/3/2021','234567891','Goldman Sachs','finance/banking',291.5,7,2.5,900000,291.5,296,290,292,'hold');
INSERT INTO `STOCK` VALUES('8/10/2021','981542267','Google','technology',835,25,3.1,8000000,835,840,832,835.5,'buy');
INSERT INTO `STOCK` VALUES('7/15/2021','785112123','AWS','technology',35,1.25,1.4,6500000,35,35.8,34,34.6,'buy');
INSERT INTO `STOCK` VALUES('8/14/2021','785112123','AWS','technology',36.5,1.25,1.25,6500000,36,36.5,35.7,36.4,'sell');

-- example 6: get the stock details involved in the portfolios
SELECT PORTFOLIO.portfolio_id, PORTFOLIO.stock, PORTFOLIO.stock_action,
STOCK.dates, STOCK.industry, STOCK.current_price, STOCK.dividend_per_share, STOCK.volatility
FROM PORTFOLIO
LEFT JOIN STOCK ON 
PORTFOLIO.stock = STOCK.stock
and PORTFOLIO.portfolio_id = STOCK.portfolio_id
and PORTFOLIO.stock_action = STOCK.stock_action;

