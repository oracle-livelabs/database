package com.example.formula1;

import java.sql.Connection;
import java.sql.SQLException;

import oracle.ucp.jdbc.PoolDataSource;
import oracle.ucp.jdbc.PoolDataSourceFactory;

public class Connections {

    /**
     * The UCP connection pool should be initialized one and reused 
     * across requests in a real application.
     */
    public static Connection get(String[] args) throws SQLException {
        PoolDataSource pool = PoolDataSourceFactory.getPoolDataSource();
        pool.setURL("jdbc:oracle:thin:hol23c/Welcome123#@23cfdrhol.livelabs.oraclevcn.com:1521/freepdb1");
        pool.setConnectionFactoryClassName("oracle.jdbc.pool.OracleDataSource");
        return pool.getConnection();
    }

}
