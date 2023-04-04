-- Drop BANK_GRAPH and tables if they exist
DROP PROPERTY GRAPH BANK_GRAPH;

drop table if exists bank_transfers;
drop table if exists bank_accounts;

-- create BANK ACCOUNTS table
CREATE TABLE BANK_ACCOUNTS (
    ID              NUMBER,
    NAME            VARCHAR(400),
    BALANCE         NUMBER(20,2)
);

-- create BANK_TRANSFERS table
CREATE TABLE BANK_TRANSFERS (
    TXN_ID          NUMBER,
    SRC_ACCT_ID     NUMBER,
    DST_ACCT_ID     NUMBER,
    DESCRIPTION     VARCHAR(400),
    AMOUNT          NUMBER
);

load bank_transfers /home/oracle/examples/graph/23c-demo/23c-demo/BankGraphDataset/BANK_TRANSFERS.csv;
load bank_accounts /home/oracle/examples/graph/23c-demo/23c-demo/BankGraphDataset/BANK_ACCOUNTS.csv;

-- Add constraints
ALTER TABLE BANK_ACCOUNTS ADD PRIMARY KEY (ID);
ALTER TABLE BANK_TRANSFERS ADD PRIMARY KEY (TXN_ID);
ALTER TABLE BANK_TRANSFERS MODIFY SRC_ACCT_ID REFERENCES BANK_ACCOUNTS (ID);
ALTER TABLE BANK_TRANSFERS MODIFY DST_ACCT_ID REFERENCES BANK_ACCOUNTS (ID);

-- Optionally verify constraints
SELECT * FROM USER_CONS_COLUMNS WHERE table_name IN ('BANK_ACCOUNTS', 'BANK_TRANSFERS');