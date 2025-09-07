# 📦 Salesforce Model Evaluation Framework

This framework defines how to consistently evaluate and compare LLMs that build Salesforce applications using Cline and a standardized prompt-based workflow with comprehensive planning and execution quality analysis.

---

## 🧭 Overview

This process is designed to:

- Compare different LLMs using **identical inputs and prompts**
- Evaluate real-world Salesforce app builds (e.g., Apex, LWC, Flow, Metadata)
- Use **Scratch Orgs** as a platform-grounded validator
- Score output across **9 core evaluation dimensions** plus **enhanced value facets**
- Conduct **comprehensive planning and execution quality analysis**
- Ensure a **fair and repeatable** benchmarking process with detailed comparative assessment

---

## 🔁 Enhanced Evaluation Process

### **Phase 1: Application Development & Deployment**
1. **Use a detailed 1-shot prompt** that fully defines the application use case (same across all models). [The prompt used.](prompt.md)
2. **Provide identical follow-up messages** or conversational prompts to each model run.
3. Let Cline **autonomously plan and generate** the application with as little additional input as possible.
4. **Deploy the generated app** into a fresh **Salesforce Scratch Org**.
5. After deployment, **export:**
   - All generated files and artifacts (the entire produced Salesforce application)
   - Details of the plan into `./plan.md`
   - Details of the act into `./act.md`
   - Cline's full **task history** in `cline_task_logs.md`

### **Phase 2: Technical Validation**
6. **Parse the export** into a normalized JSON structure (one file per run).
7. Run **validation checks** against the deployed Scratch Org:
   - Metadata deploy success/failure
   - Apex compilation status
   - Unit test coverage and execution
   - Field & object existence validation
   - Business logic functionality verification

### **Phase 3: Comprehensive Quality Analysis**
8. **Execute standardized quality assessment** using the comprehensive planning and execution analysis framework:
   - **Planning Phase Quality Assessment**: Requirements analysis, methodology evaluation, compliance scoring
   - **Execution Phase Quality Assessment**: Implementation fidelity, plan-to-execution alignment analysis
   - **Enhanced Value Facets Analysis**: Context management, comparative performance, business impact assessment
   - **Comprehensive Scoring Framework**: Multi-dimensional quality scoring with industry benchmarking
9. **Generate detailed quality report** saved as `evaluation_quality_assessment.md` in each eval directory

### **Phase 4: Comparative Analysis & Benchmarking**
10. **Score output** against both core dimensions and enhanced quality metrics.
11. **Conduct cross-model comparative analysis** with industry benchmarking.
12. **Aggregate scores** across use cases and model pairs for final comparison with detailed variance analysis.

---

## 📊 Core Evaluation Dimensions

### **Primary Technical Dimensions (1-9)**

| #  | Dimension              | Description                                                                 |
|----|------------------------|-----------------------------------------------------------------------------|
| 1  | **Functional Correctness** | Do artifacts deploy and function as intended in Salesforce?                  |
| 2  | **Metadata Awareness**     | Does the model understand Salesforce objects, fields, flows, permissions?    |
| 3  | **Interconnectedness**     | Are object relationships and references valid and consistent?               |
| 4  | **DX Project Structure**   | Are files organized per Salesforce DX conventions with proper naming?       |
| 5  | **Cost Efficiency**        | Token usage and cost per successful build (based on Cline logs)             |
| 6  | **Prompt Fidelity**        | Did the model follow the prompt's instructions and constraints?             |
| 7  | **Hallucination Rate**     | Are fake fields, objects, or metadata introduced?                           |
| 8  | **Reasoning Quality**      | Did the Plan phase show sound logic, sequencing, and completeness?          |
| 9  | **Salesforce API Usage**   | Are appropriate platform APIs recommended and used (Metadata, Tooling, etc)?|

### **Enhanced Quality Assessment Dimensions**

#### **Planning & Execution Quality (10-15)**
| #  | Dimension              | Description                                                                 |
|----|------------------------|-----------------------------------------------------------------------------|
| 10 | **Planning Methodology** | Requirements analysis quality, technical specification completeness         |
| 11 | **Execution Fidelity**   | Plan-to-implementation alignment and enhancement delivery                   |
| 12 | **Context Management**   | Token utilization efficiency and resource optimization                     |
| 13 | **Business Value**       | Production readiness and stakeholder value delivery                        |
| 14 | **Standards Compliance** | Platform best practices and enterprise development standards adherence     |
| 15 | **Model Sophistication** | Decision quality, problem-solving methodology, and adaptability            |

#### **Comparative Performance Indicators (16-18)**
| #  | Dimension              | Description                                                                 |
|----|------------------------|-----------------------------------------------------------------------------|
| 16 | **Industry Benchmark**  | Performance vs traditional development and industry standards               |
| 17 | **Development Velocity** | Speed, quality, and efficiency balance assessment                          |
| 18 | **Innovation Factor**    | Enhancement delivery beyond basic requirements                              |

---

## 📝 Enhanced Evaluation Notes

### **Core Evaluation Principles**
- ✅ Each model is tested in **isolation** in a clean Scratch Org
- 🧠 Planning and execution are assessed via comprehensive quality analysis framework
- 📦 Output is scored using **automated validators**, **detailed quality assessment**, and **comparative benchmarking**
- 📁 All results (raw, parsed, scored, quality assessments) are stored in **JSON + Markdown** for traceability
- 🎯 **Standardized assessment prompt** ensures consistent evaluation across all model runs
- 📊 **Industry benchmarking** provides context for comparative performance analysis

### **Quality Assessment Framework**
- 📋 **Planning Phase Analysis**: Requirements capture, methodology evaluation, technical specification quality
- 🚀 **Execution Phase Analysis**: Implementation fidelity, plan-to-execution alignment, enhancement delivery
- 💎 **Enhanced Value Facets**: Context management, business impact, standards compliance, model sophistication
- 🏆 **Comparative Performance**: Industry benchmarking, development velocity, innovation factors
- 📈 **Comprehensive Scoring**: Multi-dimensional quality assessment with weighted final scores

### **Output Artifacts**
Each evaluation generates:
- `plan.md` - Planning phase documentation
- `act.md` - Execution phase documentation  
- `cline_task_logs.md` - Complete task history and metrics
- `evaluation_quality_assessment.md` - **Comprehensive quality analysis report**
- Application source code and metadata files
- Deployment validation results

---

## 🔍 Analysis Framework

### **Key Assessment Questions**

#### **Compliance & Standards**
- Has the model/agent followed the rules and constraints given?
- Did everything compile and deploy successfully?
- Are platform best practices and enterprise standards followed?

#### **Performance Metrics**
- What are the number of requests for plan and act modes?
- What are the input/output token usage patterns for plan and act modes?
- Was context auto-compaction triggered and handled effectively?
- What was the total cost of the task and cost efficiency per component?

#### **Quality & Methodology**
- Did the model demonstrate systematic planning and execution methodology?
- What was the plan-to-execution alignment percentage?
- How did the implementation compare to industry benchmarks?
- What enhancements were delivered beyond basic requirements?

#### **Issue Analysis**
- Did the model have any issues in plan mode and how were they resolved?
- What types of issues occurred in act mode and what was the resolution approach?
- What critical issues need remediation for production readiness?

#### **Value Delivery**
- What is the production readiness assessment score?
- How does the business value delivery compare to requirements?
- What innovations and optimizations were implemented?

---

## 🏗️ Base Application Setup
For each evaluation, a new scratch org is used that contains a pre-configured Ingredient__c object with standard fields to provide a consistent baseline for testing.

## 📋 Standardized Prompt Framework
The evaluation uses a detailed, standardized prompt that defines the complete application use case, ensuring consistent inputs across all model comparisons. See `prompt.md` for the complete specification.

