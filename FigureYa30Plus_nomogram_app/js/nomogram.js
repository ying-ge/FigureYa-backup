/**
 * Nomogram Calculator - 基于Cox回归模型的生存率计算器
 * 基于FigureYa30nomogram_update模块的Cox模型
 */

// Cox回归模型系数
const COEFFICIENTS = {
    age: 0.032175,
    catbili_medium: 1.408395,
    catbili_high: 1.811699,
    sex_m: -0.258128,
    copper: 0.003118,
    stage: 0.543079,
    trt: 0.110627
};

// 基线风险函数参数（近似值）
const BASELINE_HAZARD = {
    // 基于R模型输出的基线生存函数
    // 使用指数分布近似
    lambda: 0.0004  // 近似的基线风险率
};

/**
 * 分类胆红素水平
 * @param {number} bili - 胆红素值 (mg/dL)
 * @returns {string} 分类结果: 'low', 'medium', 'high'
 */
function categorizeBilirubin(bili) {
    if (bili <= 2) return 'low';
    if (bili <= 4) return 'medium';
    return 'high';
}

/**
 * 计算线性预测值 (Linear Predictor)
 * @param {Object} params - 患者参数
 * @returns {number} 线性预测值
 */
function calculateLinearPredictor(params) {
    let lp = 0;

    // 年龄
    lp += COEFFICIENTS.age * params.age;

    // 胆红素分类
    const biliCategory = categorizeBilirubin(params.bili);
    if (biliCategory === 'medium') {
        lp += COEFFICIENTS.catbili_medium;
    } else if (biliCategory === 'high') {
        lp += COEFFICIENTS.catbili_high;
    }

    // 性别 (参考组是女性)
    if (params.sex === 'm') {
        lp += COEFFICIENTS.sex_m;
    }

    // 铜
    lp += COEFFICIENTS.copper * params.copper;

    // 疾病分期
    lp += COEFFICIENTS.stage * params.stage;

    // 治疗方案
    lp += COEFFICIENTS.trt * params.trt;

    return lp;
}

/**
 * 计算基线生存概率
 * @param {number} time - 时间 (天)
 * @returns {number} 基线生存概率
 */
function calculateBaselineSurvival(time) {
    // 使用指数分布近似
    return Math.exp(-BASELINE_HAZARD.lambda * time);
}

/**
 * 计算个体生存概率
 * @param {number} linearPredictor - 线性预测值
 * @param {number} time - 时间 (天)
 * @returns {number} 生存概率 (0-1)
 */
function calculateSurvival(linearPredictor, time) {
    const baselineSurvival = calculateBaselineSurvival(time);
    const individualSurvival = Math.pow(baselineSurvival, Math.exp(linearPredictor));
    return individualSurvival;
}

/**
 * 计算多个时间点的生存率
 * @param {Object} params - 患者参数
 * @returns {Object} 不同时间点的生存率
 */
function calculateNomogram(params) {
    // 验证输入参数
    if (params.age === undefined || params.bili === undefined || params.copper === undefined ||
        params.sex === undefined || params.stage === undefined || params.trt === undefined) {
        throw new Error('缺少必要的输入参数');
    }

    // 计算线性预测值
    const linearPredictor = calculateLinearPredictor(params);

    // 计算不同时间点的生存率
    const timePoints = {
        '2y': 2 * 365.25,    // 2年
        '5y': 5 * 365.25,    // 5年
        '8y': 8 * 365.25     // 8年
    };

    const results = {};
    for (const [label, time] of Object.entries(timePoints)) {
        const survival = calculateSurvival(linearPredictor, time);
        results[label] = survival;
    }

    return {
        linearPredictor: linearPredictor,
        survivals: results,
        riskScore: Math.exp(linearPredictor)
    };
}

/**
 * 格式化生存率为百分比
 * @param {number} survival - 生存概率 (0-1)
 * @returns {string} 格式化的百分比
 */
function formatSurvivalPercentage(survival) {
    const percentage = (survival * 100);
    return `${percentage.toFixed(1)}%`;
}

/**
 * 解析表单输入数据
 * @param {HTMLFormElement} form - 表单元素
 * @returns {Object} 解析后的参数对象
 */
function parseFormData(form) {
    return {
        age: parseFloat(form.elements.age?.value || 0),
        sex: form.elements.sex?.value || '',
        bili: parseFloat(form.elements.bili?.value || 0),
        copper: parseFloat(form.elements.copper?.value || 0),
        stage: parseInt(form.elements.stage?.value || 0),
        trt: parseInt(form.elements.trt?.value || 0)
    };
}

/**
 * 验证输入数据
 * @param {Object} params - 患者参数
 * @returns {Object} 验证结果
 */
function validateInput(params) {
    const errors = [];

    if (isNaN(params.age) || params.age < 0 || params.age > 120) {
        errors.push('请输入有效的年龄 (0-120岁)');
    }

    if (isNaN(params.bili) || params.bili < 0 || params.bili > 50) {
        errors.push('请输入有效的胆红素值 (0-50 mg/dL)');
    }

    if (isNaN(params.copper) || params.copper < 0 || params.copper > 1000) {
        errors.push('请输入有效的铜值 (0-1000 μg/dL)');
    }

    if (!['m', 'f'].includes(params.sex)) {
        errors.push('请选择有效的性别');
    }

    if (![1, 2, 3, 4].includes(params.stage)) {
        errors.push('请选择有效的疾病分期');
    }

    if (![0, 1, 2].includes(params.trt)) {
        errors.push('请选择有效的治疗方案');
    }

    return {
        isValid: errors.length === 0,
        errors: errors
    };
}

/**
 * 生成风险评估建议
 * @param {Object} results - 计算结果
 * @returns {string} 风险评估建议
 */
function generateRiskAssessment(results) {
    const fiveYearSurvival = results.survivals['5y'];

    if (fiveYearSurvival >= 0.8) {
        return '低风险 - 预后良好';
    } else if (fiveYearSurvival >= 0.5) {
        return '中风险 - 需要定期随访';
    } else {
        return '高风险 - 建议积极治疗';
    }
}

// 导出函数供其他模块使用
window.NomogramCalculator = {
    calculateNomogram,
    parseFormData,
    validateInput,
    formatSurvivalPercentage,
    generateRiskAssessment,
    categorizeBilirubin,
    COEFFICIENTS
};