# Introduction to Edition Based Redefinition

Edition-based redefinition (EBR) enables online application upgrade with uninterrupted availability of the application. When the installation of an upgrade is complete, the pre-upgrade application and the post-upgrade application can be used at the same time. Therefore, an existing session can continue to use the pre-upgrade application until its user decides to end it; and all new sessions can use the post-upgrade application. When there are no longer any sessions using the pre-upgrade application, it can be retired. In this way, EBR allows hot rollover from from the pre-upgrade version to the post-upgrade version, with zero downtime.

EBR enables online application upgrades in the following manner:

    Code changes are installed in the privacy of a new edition.
    Data changes are made safely by writing only to new columns or new tables not seen by the old edition. An editioning view exposes a different projection of a table into each edition to allow each to see just its own columns.
    Crossedition triggers propagate data changes made by the old edition into the new edition’s columns, or (in hot-rollover) vice-versa.

EBR is available for use in all editions of Oracle Database without the need to license it.

Estimated Workshop Time: 2 hours

Watch the video below for an overview on Oracle Edition Based Redefinition.

[EBR Introduction] (https://videohub.oracle.com/media/Oracle+DatabaseA+Edition-Based+Redefinition+%28EBR%29/1_p6bapnjx) 

### About this Workshop

Fleet Patching and Provisioning 19c is meant to be used by customers to patch their database fleet on-premises. It is generally not recommended to use it for patching Oracle Cloud database services, because the current version does not integrate with the OCI automation tooling (please note that is not completely true: Oracle does use FPP internally to patch some OCI services, but this is not visible to our customers). However, in this workshop we will use OCI services to setup and test FPP.

For the scope of this workshop, we will use two servers:

    The FPP server (fpps01), created as a single-node Virtual DB System (DBCS-VM).
    One FPP target (fppc), created on a Compute Service instance.

FPP is part of the Oracle Grid Infrastructure stack: the FPP Server requires the full GI stack installed and configured on a server or cluster. This is the reason why we will use a Virtual DB System (DBCS) for it: full Grid Infrastructure stacks cannot be provisioned on compute instances.
Workshop Objectives

    Getting acquainted with the environment and rhpctl command line tool
    Importing Gold Images
    Provisioning Oracle Restart environments
    Installing Oracle Homes (Working Copies)
    Creating and patching Oracle Databases

Workshop Prerequisites

    A Free Tier, Paid or LiveLabs Oracle Cloud account
    SSH Private Key to access the host via SSH

More Information on Oracle Fleet Patching & Provisioning

    FPP documentation
    FPP website

Acknowledgements

    Author - Ludovico Caldara
    Contributors - Suraj Ramesh
    Last Updated By/Date -Suraj Ramesh, July 2022
