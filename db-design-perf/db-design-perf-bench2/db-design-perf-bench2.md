# Optimize the design for throughput

## Introduction

In this lab, you will modify the physical design to improve benchmark performance.

Estimated lab time: 10 minutes

### Prerequisites

-   This lab requires completing the preceding labs in the Contents menu on the left.

## Task 1: Run the New Benchmark via Cloud Shell

1. Using Cloud Shell, run the benchmark2 shell script.

  If you are already in the home directory, you can skip the initial CD command.

    ```
    <copy>
    cd ~
    ./benchmark2.sh
    </copy>
    ```

    The script will connect to your autonomous database and rebuilds the schema from scratch.  The only elements presented verbosely on screen are those changed from the initial baseline.

    ![Show the difference in table setup comparted to Benchmark 1](./images/t1-show-difference-in-table-compared-to-benchmark1.png " ")

    The first change here focuses on reducing the number of database **triggers** down to a minimum. There is a performance cost to firing a trigger during a DML operation. Sometimes the complexity of business requirements makes a trigger mandatory, but often, triggers are used to populate potentially missing column values. A column has *always* had the ability to be given a default value, but triggers were used to ensure that a NULL could never be forcibly inserted into such columns.

    However, from Oracle Database 12c onwards, the DEFAULT ON NULL clause means that the need for triggers to capture default values is often no longer the case.  Default values (fixed or based on, for example, sequences), user login, and context values can be applied natively in the table definition.

    As the schema generation continues, you will see that all of the trigger creation code is no longer required, as has been commented out.

    ![No more triggers available in the benchmark schema](./images/t2-no-more-triggers-created-in-schema.png " ")

    The script will pause when it has rebuilt the schema back to the state and is ready to launch the benchmark.

    ![The benchmark will start in 5 seconds](./images/t3-benchmark-will-start-in-5-seconds.png " ")

    Because you are familiar with the benchmark process, the eight sessions will be launched, and the initiating commit will occur automatically. Thus you need to wait for the benchmark to complete.

## Task 2: Review results

1. The benchmark will produce a similar performance summary to the first execution.

    ![Results of benchmark 2](./images/t4-results-of-benchmark-2.png " ")

    As mentioned earlier, your results will be different, but using the results in the image above, you can observe that with the revised design, which has eliminated triggers:

    - Throughput has improved **2609** transactions per second (up from 1524)
    - Elapsed time per session has improved to **31** seconds (down from 52)
    - CPU time is still at only **51** per cent of the total benchmark time

    The results here should not be understated. Often when tuning applications, a few percentage points is seen as a "win", but in this instance, the performance has almost doubled by simply utilising the DEFAULT ON NULL database feature. However, CPU is still not the major contributor to total elapsed time, which suggests potentially more benefits.

If you have not done so already, press Enter to exit the benchmark and please **proceed to the next lab.**

## Want to Learn More?

For more information on the [DEFAULT ON NULL](https://blogs.oracle.com/oraclemagazine/improved-defaults-in-oracle-database-12c) clause.

## Acknowledgements

- **Author** - Connor McDonald, Database Advocate
- **Last Updated By/Date** - Robert Pastijn, September 2022