# Comprehensive Planning & Execution Quality Analysis Prompt

Use this prompt to conduct standardized analysis of AI model performance across planning and execution phases for any software development project.

---

## **Analysis Instructions**

Analyze the provided codebase evaluation directory and conduct a comprehensive planning and execution quality assessment. The models used and total costs are in `evaluation_task_log.md`.

The original prompt is in ./prompt.md.

**Required Inputs to ask me for:**
1. **Eval Run ID**: [Specify the evaluation directory name]

**Analysis Scope:**
- Read and analyze `plan.md` (planning phase)
- Read and analyze `act.md` (execution phase) 
- Review all application components and code files
- Examine any available task logs for context

**Output Location**: Save results to `evaluation_quality_assessment.md` in the same directory as the analysis.

---

## **Analysis Framework**

Conduct comprehensive assessment across the following dimensions:

### **1. Planning Phase Quality Assessment**

#### **Planning Methodology Evaluation**
- **Requirements Analysis Quality**: Completeness of requirement capture and decomposition
- **Current State Analysis**: Assessment of existing components and gap identification
- **Project Structure & Organization**: Logical phase breakdown and dependency management
- **Technical Specification**: Detail level of field names, types, and relationships
- **Architecture Planning**: Design pattern selection and technical implementation strategy

#### **Requirements Compliance in Planning**
- **Data Model Planning**: Completeness of object and field specifications
- **Business Logic Planning**: Coverage of all business rules and automation requirements
- **UI Requirements Planning**: Completeness of user interface specifications
- **Security Planning**: Permission sets, access control, and security model planning
- **Testing Strategy**: Test planning comprehensiveness and approach

#### **Planning Quality Scoring**
Rate each area 1-5 and provide overall planning quality score with detailed rationale.

### **2. Execution Phase Quality Assessment**

#### **Execution Methodology Evaluation**
- **Documentation Quality**: Completeness and accuracy of results documentation
- **Results Reporting**: Transparency and detail in outcome reporting
- **Implementation Details**: Technical depth and architecture pattern documentation
- **Issue Identification**: Honesty and completeness in problem reporting

#### **Plan-to-Execution Alignment Analysis**
Create detailed comparison tables for:
- **Data Model Implementation**: Planned vs executed components with alignment percentages
- **Business Logic Implementation**: Planned vs executed logic with fidelity assessment
- **UI Implementation**: Planned vs executed features with enhancement tracking
- **Security Implementation**: Planned vs executed security measures

#### **Execution Quality Scoring**
Rate execution fidelity, enhancement delivery, and problem resolution with detailed analysis.

### **3. Enhanced Analysis: Additional Value Facets**

#### **Context Management & Resource Efficiency**
- **Token Utilization Effectiveness**: Usage patterns, efficiency metrics, auto-compaction handling
- **Development Velocity Metrics**: Components delivered, success rates, problem resolution speed
- **Resource Optimization Patterns**: Context management, tool usage efficiency, cost control
- **Cost Efficiency Analysis**: Cost per component, total cost analysis, value delivery assessment

#### **Comparative Model Performance Benchmarking**
- **Multi-Model Quality Comparison Matrix**: Against industry standards and other models
- **Capability Maturity Assessment**: Strategic vs tactical approach, technical sophistication level
- **Industry Benchmark Comparison**: Quantified performance vs traditional development and standards

#### **Quality Progression Analysis**
- **Phase-by-Phase Quality Evolution**: Track quality improvements across development phases
- **Learning and Adaptation Patterns**: Progressive enhancement, technology adaptation, problem-solving evolution
- **Enhancement Factor Calculation**: Quantify improvements beyond basic requirements

#### **Business Impact & Value Delivery Assessment**
- **Functional Completeness vs Business Value**: Core processes vs value-added features analysis
- **Production Readiness Assessment**: Scalability, maintenance cost, user adoption readiness
- **Business Impact Quantification**: Immediate value, long-term benefits, ROI considerations

#### **Risk Assessment & Production Readiness Matrix**
- **Security and Compliance Risk Analysis**: Risk categorization with severity levels
- **Technical Debt and Maintainability Scoring**: Code quality, documentation, refactoring requirements
- **Production Blocker Identification**: Critical issues preventing deployment

#### **Development Standards Compliance Deep-Dive**
- **Platform Best Practices Compliance**: Framework-specific best practices adherence
- **Enterprise Development Standards**: Documentation, testing, security, architecture compliance
- **Granular Standards Breakdown**: Detailed compliance matrix with specific percentages

#### **Model Behavior & Decision Quality Analysis**
- **Architectural Decision Excellence**: Decision rationale, alternatives considered, impact assessment
- **Problem-Solving Methodology**: Systematic approach, constraint handling, innovation balance
- **Adaptability Assessment**: Flexibility in responding to implementation realities

#### **Implementation Efficiency & Delivery Metrics**
- **Development Velocity Analysis**: Quantified speed, quality, efficiency metrics
- **Delivery Excellence Indicators**: Scope delivery, quality delivery, timeline adherence
- **Value Creation Assessment**: Stakeholder value, enhancement delivery, innovation factor

#### **Advanced Comparative Analysis**
- **AI Development Methodology Maturity**: Strategic thinking, technical execution, documentation practice
- **Industry Benchmark Comparison**: vs traditional development, other AI models, industry standards
- **Capability Assessment**: Technical depth, problem-solving sophistication, professional methodology

### **4. Comprehensive Scoring Framework**

#### **Primary Quality Scores (1-5 scale)**
- **Planning Quality**: Overall planning methodology and completeness
- **Execution Quality**: Implementation fidelity and enhancement delivery
- **Plan-to-Execution Alignment**: Adherence to planned approach and scope

#### **Enhanced Quality Metrics**
- **Context Management Efficiency**: Resource utilization and optimization
- **Business Value Delivery**: Functional completeness and production readiness
- **Development Standards Compliance**: Best practices and enterprise standards adherence
- **Model Sophistication**: Decision quality and problem-solving methodology

#### **Comparative Performance Indicators**
- **Industry Benchmark Score**: Performance vs industry standards (percentage above/below)
- **Cost Efficiency Rating**: Value delivery per unit cost
- **Development Velocity Score**: Speed and quality balance assessment

### **5. Issue Identification & Recommendations**

#### **Critical Issues (Must Fix)**
- Identify production blockers and compliance failures
- Provide specific remediation steps and priorities

#### **Medium Priority Issues**
- Document quality improvements and enhancement opportunities
- Suggest implementation approaches and timelines

#### **Enhancement Opportunities**
- Identify innovation possibilities and future value creation
- Recommend advanced features and optimizations

### **6. Final Assessment & Executive Summary**

#### **Overall Quality Score Calculation**
- Weighted scoring across all dimensions
- Final quality rating with detailed breakdown
- Comparative assessment vs benchmarks

#### **Key Success Factors Identification**
- Highlight exceptional performance areas
- Document methodology strengths and innovations

#### **Business Impact Summary**
- Production readiness assessment
- Value delivery quantification
- ROI and stakeholder benefit analysis

#### **Strategic Recommendations**
- Immediate action items with priorities
- Long-term enhancement roadmap
- Best practice documentation for future projects

---

## **Output Format Requirements**

### **Document Structure**
```markdown
# Planning & Execution Quality Assessment

**Project**: [Project Name and Description]
**Eval Run ID**: [Directory Name] 
**Assessment Date**: [Analysis Date]
**Models Used**: [Plan Model] and [Act Model]
**Total Cost**: [Cost Amount]
**Requirements Source**: [Requirements File Path]

## Executive Summary
[Overall scores and key findings]

## Planning Phase Quality Assessment
[Detailed planning analysis with scores]

## Execution Phase Quality Assessment  
[Detailed execution analysis with scores]

## Enhanced Analysis: Additional Value Facets
[Comprehensive enhanced analysis sections]

## Overall Assessment
[Final scoring and recommendations]

## Enhanced Conclusion and Executive Summary
[Strategic insights and comparative analysis]
```

### **Scoring Display Format**
- Use star ratings: ⭐⭐⭐⭐⭐ (5/5) with numerical scores
- Include comparison tables with alignment percentages
- Use status indicators: ✅ ❌ ⚠️ for quick scanning
- Provide quantified metrics where possible

### **Visual Elements**
- Use code blocks for technical examples
- Include comparison matrices and tables
- Provide bullet points for easy scanning
- Use clear section headers and subsections

---

## **Search and Analysis Instructions**

### **File Analysis Priority**
1. **Primary Documents**: plan.md, act.md, requirements/prompt files
2. **Code Implementation**: All source code files, metadata, configurations
3. **Documentation**: README files, technical documentation
4. **Testing**: Test classes, test results, coverage reports
5. **Deployment**: Deployment logs, success/failure indicators

### **Key Patterns to Search For**
- **Planning Quality**: Requirements coverage, technical specifications, constraint management
- **Execution Fidelity**: Implementation alignment, enhancement delivery, issue resolution
- **Code Quality**: Best practices, design patterns, security implementation
- **Performance Metrics**: Efficiency indicators, resource utilization, delivery speed
- **Business Value**: Functional completeness, production readiness, value-added features

### **Quantification Requirements**
- Extract specific metrics: token usage, costs, component counts, success rates
- Calculate percentages: compliance rates, alignment scores, improvement factors
- Identify trends: quality progression, enhancement patterns, efficiency improvements
- Benchmark comparisons: industry standards, best practices, other implementations

---
