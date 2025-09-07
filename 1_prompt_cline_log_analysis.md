# Cline Task Log Analysis Prompt

Analyze the provided cline task log file and extract comprehensive details and metrics. 

Ask me the following:
1. Prompt me for the total cost of the task. Use this in the report.
2. Prompt me for the Eval Run ID which correlates to a directory under /evals. Use the `cline_task_logs.md` file in that diretory. Create a `evaluation_task_log.md` file /evals/[Eval Run ID] with the following.

Provide a structured report covering the following areas:

## **Task Overview & Context**
- Extract the main task/project objective
- Identify AI models used (plan model vs act model)
- Note the eval run ID and any project identifiers
- Summarize the domain/technology stack involved

## **Performance Metrics**

### **Resource Utilization**
- Track token usage progression throughout the session
- Note peak token usage and percentage of limit reached
- Identify any context window management issues
- Record execution timing measurements (look for "Elapsed Time" entries)

### **Mode-Specific Metrics**
- **Plan Mode Analysis**:
  - Count number of requests in plan mode
  - Extract input and output token usage for plan mode
  - Calculate total time elapsed for plan mode
  - Identify any issues or failures in plan mode with details

- **Act Mode Analysis**:
  - Count number of requests in act mode
  - Extract input and output token usage for act mode
  - Calculate total time elapsed for act mode
  - Identify any issues or failures in act mode with details

### **System Performance**
- Count instances of context auto-compaction
- Calculate total cost of the task (if cost information is available)
- Track context window management and optimization

### **Progress Tracking**
- Extract todo list completion percentages
- Count total tasks/items completed vs planned
- Note any progress indicators or milestone achievements
- Track completion rates across different phases

## **Technical Implementation Analysis**

### **Components Created**
- Count total files/components created
- Categorize by type (data model, business logic, UI, tests, etc.)
- List specific technologies used (Apex, Lightning Web Components, etc.)
- Note any configuration or metadata files

### **Development Quality Indicators**
- Identify code quality practices mentioned (bulkification, error handling, security)
- Note any validation or input checking implementations
- Extract security considerations and implementations
- Identify design patterns or architectural decisions

## **Testing & Quality Assurance**

### **Test Execution Results**
- Count total test methods created
- Calculate pass/fail rates
- Categorize failure types and root causes
- Note any debugging cycles or iterative fixes

### **Deployment Status**
- Track deployment success/failure rates
- Identify deployment issues and resolutions
- Note any rollback or retry scenarios
- Extract validation or compilation errors

## **Error Analysis & Problem Solving**

### **Error Patterns**
- Categorize types of errors encountered
- Note frequency of specific error types
- Track error resolution approaches
- Identify recurring issues or blockers

### **Debugging Efficiency**
- Count debugging iterations per issue
- Note time spent on problem resolution
- Track success rate of fix attempts
- Identify most effective debugging strategies

## **Workflow & Process Metrics**

### **Development Phases**
- Identify distinct phases of development
- Track time/effort distribution across phases
- Note any phase dependencies or blockers
- Extract phase completion indicators

### **Communication Patterns**
- Count user-assistant interaction exchanges
- Note clarification requests and responses
- Track context switching or scope changes
- Identify decision points and outcomes

## **Tool Usage & Efficiency**

### **Tool Call Analysis**
- Count different types of tool calls used
- Note tool usage patterns and frequency
- Identify most/least effective tools
- Track tool call success rates

### **File System Operations**
- Count file reads, writes, and modifications
- Track directory navigation patterns
- Note file organization strategies
- Identify any file management issues

## **Success Indicators & Outcomes**

### **Deliverable Completion**
- List all successfully completed deliverables
- Note partially completed or failed components
- Track requirement fulfillment percentage
- Identify any scope creep or changes

### **Quality Metrics**
- Extract any code coverage percentages
- Note compliance with coding standards
- Track security implementation completeness
- Identify performance considerations

## **Learning & Adaptation Patterns**

### **Problem-Solving Evolution**
- Track how approaches evolved during the session
- Note learning from previous errors
- Identify strategy adjustments
- Extract insights gained during development

### **Efficiency Improvements**
- Note any process optimizations discovered
- Track speed improvements over time
- Identify successful shortcuts or patterns
- Note avoided pitfalls or anti-patterns

## **Rule Compliance Analysis**

### **Adherence to Cline Rules**
- Analyze compliance with rules specified in `./cline-rules.md`
- Check for violations of Salesforce development best practices
- Verify proper naming conventions were followed
- Assess adherence to code organization and structure guidelines
- Evaluate compliance with testing requirements (90% coverage, proper test patterns)
- Check for proper security implementation (`with sharing`, `WITH SECURITY_ENFORCED`)
- Verify governor limits compliance (no SOQL/DML in loops, bulkification)
- Assess permission set creation and documentation requirements
- Check for proper error handling and logging patterns
- Verify proper documentation standards were followed

### **Specific Rule Violations**
- List any explicit violations of stated rules with line references
- Note areas where best practices were not followed
- Identify missing required components (permission sets, documentation, etc.)
- Highlight any prohibited practices that were used

## **Final Assessment**

### **Overall Success Rate**
- Calculate percentage of requirements met
- Note critical vs nice-to-have features completed
- Assess system functionality and usability
- Evaluate deployment readiness

### **Key Takeaways**
- Identify most significant challenges overcome
- Note most effective strategies used
- Extract lessons learned for future projects
- Summarize critical success factors

---

## **Output Format Requirements**

Present findings in a structured format with:
- Clear section headers and subsections
- Quantitative metrics where available (percentages, counts, times)
- Qualitative assessments with supporting evidence
- Visual indicators (✅ ❌ ⚠️) for status items
- Bullet points for easy scanning
- Code blocks for technical details when relevant

## **Search Instructions**

When analyzing the log file:

### **General Patterns**
1. Search for patterns like "Elapsed Time", "tokens used", "Progress", "completed"
2. Look for deployment results, test outcomes, and error messages
3. Count occurrences of successful operations vs failures
4. Extract specific technical terms and technologies mentioned
5. Identify file creation/modification timestamps and sequences
6. Track user interactions and assistant responses
7. Note any performance benchmarks or measurements

### **Mode-Specific Searches**
8. Search for "Plan Mode" vs "Act Mode" indicators to separate metrics
9. Look for request counts and token usage by mode
10. Track time elapsed for each mode separately
11. Identify mode-specific issues and error patterns

### **Rule Compliance Searches**
12. Search for Salesforce-specific patterns: `with sharing`, `WITH SECURITY_ENFORCED`, bulkification patterns
13. Look for test coverage percentages and testing patterns
14. Search for permission set creation and documentation
15. Check for proper naming conventions in class and method names
16. Verify proper error handling patterns and logging

### **Cost and Context Management**
17. Search for "context auto-compacted" or similar compaction indicators
18. Look for cost calculations or pricing information
19. Track context window usage and management strategies

### **Specific Search Terms**
- **Tokens**: "input tokens", "output tokens", "tokens used", "context window"
- **Timing**: "Elapsed Time", "Duration", "started", "completed"
- **Modes**: "Plan Mode", "Act Mode", "planning", "acting"
- **Issues**: "Error", "Failed", "Exception", "Problem", "Issue"
- **Compliance**: "with sharing", "Security", "Permission", "Test coverage"
- **Context**: "auto-compacted", "context window", "compaction"
- **Cost**: "cost", "price", "$", "billing"

Focus on extracting actionable insights that would help evaluate AI coding assistant performance across different tasks and compare effectiveness between different models or approaches.
