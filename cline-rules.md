# Salesforce Development Rules for Cline

## General Development Principles

- Follow these rules at all times. Ask clarifying questions when instructions are unclear
- When creating new objects and classes, always create XML metadata files for objects (.object-meta.xml) and classes (.cls-meta.xml)
- When calling the Salesforce CLI, always use `sf`, never use `sfdx`

### 1. Code Organization & Structure
- Follow consistent naming conventions (PascalCase for classes, camelCase for methods/variables)
- Use descriptive, business-meaningful names for classes, methods, and variables
- Write code that is easy to maintain, update and reuse
- Organize code into logical packages and maintain clear separation of concerns
- Include comprehensive JavaDoc comments for all public methods and classes
- Include comments explaining key design decisions. Don't explain the obvious
- Use consistent indentation (2 spaces) and formatting
- Less code is better, best line of code is the one never written. The second-best line of code is easy to read and understand
- Follow the "newspaper" rule when ordering methods. They should appear in the order they're referenced within a file. Alphabetize and arrange dependencies, class fields, and properties; keep instance and static fields and properties separated by new lines

### 2. Apex Best Practices

#### General
- For automation, favor Apex over Flow
- Write Invocable Apex that can be called from flows when possible
- Use enums over string constants whenever possible. Enums should follow ALL_CAPS_SNAKE_CASE without spaces
- Use Database Methods for DML Operation with exception handling
- Use Return Early pattern

#### Apex Triggers
- Follow the One Trigger Per Object pattern
- Implement a trigger handler class to separate trigger logic from the trigger itself
- Use trigger context variables (Trigger.new, Trigger.old, etc.) efficiently to access record data
- Avoid logic that causes recursive triggers, implement a static boolean flag
- Bulkify trigger logic to handle large data volumes efficiently
- Implement before and after trigger logic appropriately based on the operation requirements
- Use ApexDocs comments to document the trigger and handler class for better maintainability

#### Governor Limits Compliance
- Always write bulkified code - never perform SOQL/DML operations inside loops
- Use collections for bulk processing
- Implement proper exception handling with try-catch blocks
- Limit SOQL queries to 100 per transaction
- Limit DML statements to 150 per transaction
- Use `Database.Stateful` interface only when necessary for batch jobs

#### SOQL Optimization
- Use selective queries with proper WHERE clauses
- Do not use `SELECT *` - it is not supported in SOQL
- Use indexed fields in WHERE clauses when possible
- Implement SOQL best practices: LIMIT clauses, proper ordering
- Use `WITH SECURITY_ENFORCED` for user context queries where appropriate

#### Security & Access Control
- Always check field-level security (FLS) before accessing fields
- Implement proper sharing rules and respect organization-wide defaults
- Use `with sharing` keyword for classes that should respect sharing rules
- Validate user permissions before performing operations
- Sanitize user inputs to prevent injection attacks

### 3 Flow Development
- Handle Errors With Fault Paths
- Exception Handling In Flow Using Platform Events
- Document Flows
- Use proper flow naming conventions

### 4. Lightning Web Components (LWC) Standards

#### Component Architecture
- Create reusable, single-purpose components
- Use proper data binding and event handling patterns
- Implement proper error handling and loading states
- Follow Lightning Design System (SLDS) guidelines
- Use the lightning-record-edit-form component for handling record creation and updates
- Use CSS custom properties for theming
- Use the force:navigateToComponent event for navigation between components
- Use the lightning:availableForFlowScreens interface to make the component should be available in Flow screens by default

#### JavaScript Best Practices
- Use ES6+ features consistently
- Implement proper async/await patterns for server calls
- Handle errors gracefully with user-friendly messages
- Use wire adapters for reactive data loading
- Minimize DOM manipulation - use reactive properties

#### Performance Optimization
- Use `@track` decorator judiciously (only when necessary)
- Implement proper caching strategies
- Optimize bundle size by importing only necessary modules
- Use lazy loading for large components

### 5. Testing Requirements

#### Unit Testing Standards
- Maintain minimum 90% code coverage
- Write meaningful test assertions, not just coverage
- Use Test.startTest() and Test.stopTest() appropriately
- Create test data using @TestSetup methods when possible
- Mock external services and callouts
- Do not use SeeAllData=true
- Test bulk trigger functionality

#### Test Data Management
- Use Test.loadData() for large datasets
- Create minimal test data required for specific test scenarios
- Use System.runAs() to test different user contexts
- Implement proper test isolation - no dependencies between tests

### 6. Integration & API Guidelines

#### REST/SOAP Integration
- Implement proper timeout and retry mechanisms
- Use appropriate HTTP status codes and error handling
- Implement bulk operations for data synchronization
- Use efficient serialization/deserialization patterns
- Log integration activities for debugging

#### Platform Events
- Design events for loose coupling between components
- Use appropriate delivery modes (immediate vs. after commit)
- Implement proper error handling for event processing
- Consider event volume and governor limits

### 7. Permissions
- For every new component created, generate:
  - At least one permission set for user access
  - Documentation explaining the permission set purpose
  - Assignment recommendations
- One permission set per object per access level
- Separate permission sets for different Apex class groups
- Individual permission sets for each major feature
- No permission set should grant more than 10 different object permissions  
- Components requiring permission sets:
  - Custom objects and fields
  - Apex classes and triggers
  - Lightning Web Components
  - Visualforce pages
  - Custom tabs and applications
  - Flow definitions
  - Custom permissions
- Format: [AppPrefix]_[Component]_[AccessLevel]
  - AppPrefix: 3-8 character application identifier (PascalCase)
  - Component: Descriptive component name (PascalCase) 
  - AccessLevel: Read|Write|Full|Execute|Admin
  - Examples:
    - SalesApp_Opportunity_Read
    - OrderMgmt_Product_Write  
    - CustomApp_ReportDash_Full
    - IntegAPI_DataSync_Execute
- Label: Human-readable description
- Description: Detailed explanation of purpose and scope
- License: Appropriate user license type    
- Never grant "View All Data" or "Modify All Data" in functional permission sets
- Always specify individual field permissions rather than object-level access when possible
- Require separate permission sets for sensitive data access
- Never combine read and delete permissions in the same permission set
- Always validate that granted permissions align with business requirements
- Create permission set groups when:
  - Application has more than 3 related permission sets
  - Users need combination of permissions for their role
  - There are clear user personas/roles defined

#### Apex Permission Requirements:

- For Public/Global Classes:
  - Create [App]_ApexExec_[ClassName] permission set
  - Grant only "Execute" permission, never "Author Apex"
  - Include description of class purpose and security implications
- For Utility/Helper Classes:
  - Bundle related utility classes in single permission set
  - Use naming: [App]_Utils_Execute
  - Document all included classes
- For Integration Classes:
  - Create separate permission set: [App]_Integration_Execute
  - Include only classes used by integration user
  - Document external system dependencies
- Never grant:
  - "Author Apex" permission in functional permission sets
  - Create separate [App]_Developer_AuthorApex for developers only  

#### Custom Object Permission Requirements:

- Create hierarchical permission sets:
  1. [App]_[Object]_Read
    - Read object permission
    - Read access to essential fields only
    - Tab visibility if applicable
  2. [App]_[Object]_Write  
    - All Read permissions
    - Create and Edit object permissions
    - Write access to user-editable fields
    - Related list access
  3. [App]_[Object]_Admin
    - All Write permissions  
    - Delete permission
    - Access to all fields including system fields
    - "View All" and "Modify All" only if required

- Field Level Security
  - Explicitly grant field permissions
  - Group related fields logically
  - Separate permission sets for sensitive fields  

#### Mandatory Permission Documentation
- Permissions.md file explaining all permission sets
- Dependency mapping between permission sets  
- User role assignment matrix
- Testing validation checklist

### 8. Deployment & DevOps

#### Version Control
- Use meaningful commit messages following conventional commit format
- Create feature branches for all development work

### 9. Documentation Standards

#### Code Documentation
- Use ApexDocs comments to document classes, methods, and complex code blocks for better maintainability
- Include usage examples in method documentation
- Document business logic and complex algorithms
- Maintain up-to-date README files for each component

#### Architecture Documentation
- Document data flow and integration patterns
- Document deployment and configuration procedures

### 10. Error Handling & Logging

#### Exception Management
- Create custom exception classes for business logic errors
- Implement centralized error logging mechanism
- Provide user-friendly error messages in UI
- Log sufficient detail for debugging without exposing sensitive data

#### Debugging Support
- Use appropriate debug levels (ERROR, WARN, INFO, DEBUG)
- Include relevant context in debug statements
- Remove or minimize debug statements in production code
- Implement structured logging for better searchability

### 11. Performance Guidelines

#### Query Performance
- Use query optimization techniques (indexes, selective queries)
- Implement pagination for large result sets
- Cache frequently accessed data appropriately
- Monitor and optimize slow-performing operations

#### UI Performance
- Minimize initial component load time
- Implement progressive data loading
- Use efficient DOM update patterns
- Optimize images and static resources

### 12. Specific Coding Rules

#### Prohibited Practices
- No hardcoded IDs or URLs
- No SOQL/DML operations in loops
- No System.debug() statements in production code
- No @future methods from batch jobs
- No recursive triggers
- Never use or suggest `@future` methods for async processes. Use queueables and always suggest implementing `System.Finalizer` methods

#### Required Patterns
- Use Builder pattern for complex object construction
- Implement Factory pattern for object creation
- Use Dependency Injection for testability
- Follow MVC pattern in Lightning components
- Use Command pattern for complex business operations