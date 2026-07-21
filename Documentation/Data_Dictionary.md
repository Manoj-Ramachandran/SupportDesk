# Data Dictionary

## Customers
CustomerID, CompanyName, Industry, Country, Subscription, CustomerSince

## Products
ProductID, ProductName, Version

## Modules
Authentication, Reporting, Dashboard, License, Database, Scheduler, Notifications, Security, API, User Management

## Engineers
EngineerID, EngineerName, Experience, Team, Location, JoiningDate

## Tickets
TicketID, CustomerID, EngineerID, ProductID, ModuleID, Priority, Severity, Status, CreatedDate, AssignedDate, ResolvedDate, ResolutionHours, SLAStatus

## Releases
ReleaseID, Version, ReleaseDate, CriticalBugs, MajorBugs, MinorBugs, RegressionCount

## Feedback
FeedbackID, TicketID, Rating, Comments, FeedbackDate
