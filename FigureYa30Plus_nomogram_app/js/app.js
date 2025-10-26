/**
 * Nomogram App - 主要应用逻辑
 * 处理用户交互、表单提交、结果显示等
 */

// DOM元素
const form = document.getElementById('nomogram-form');
const calculateBtn = document.getElementById('calculate-btn');
const resultsContainer = document.getElementById('results');
const btnText = document.querySelector('.btn-text');
const btnLoading = document.querySelector('.btn-loading');

// 结果显示元素
const survival2y = document.getElementById('survival-2y');
const survival5y = document.getElementById('survival-5y');
const survival8y = document.getElementById('survival-8y');

// Nomogram可视化器
let visualizer = null;

/**
 * 显示/隐藏加载状态
 * @param {boolean} isLoading - 是否显示加载状态
 */
function setLoading(isLoading) {
    calculateBtn.disabled = isLoading;
    btnText.style.display = isLoading ? 'none' : 'inline';
    btnLoading.style.display = isLoading ? 'inline' : 'none';
}

/**
 * 显示错误消息
 * @param {string} message - 错误消息
 */
function showError(message) {
    alert(`输入错误：\n\n${message}\n\n请检查您的输入数据。`);
}

/**
 * 更新结果显示
 * @param {Object} results - 计算结果
 * @param {Object} params - 患者参数
 */
function updateResults(results, params) {
    // 更新生存率显示
    survival2y.textContent = window.NomogramCalculator.formatSurvivalPercentage(results.survivals['2y']);
    survival5y.textContent = window.NomogramCalculator.formatSurvivalPercentage(results.survivals['5y']);
    survival8y.textContent = window.NomogramCalculator.formatSurvivalPercentage(results.survivals['8y']);

    // 添加颜色指示器
    const getColorClass = (survival) => {
        if (survival >= 0.8) return 'high';
        if (survival >= 0.5) return 'medium';
        return 'low';
    };

    survival2y.className = `result-value ${getColorClass(results.survivals['2y'])}`;
    survival5y.className = `result-value ${getColorClass(results.survivals['5y'])}`;
    survival8y.className = `result-value ${getColorClass(results.survivals['8y'])}`;

    // 显示结果容器
    resultsContainer.style.display = 'block';

    // 滚动到结果区域
    setTimeout(() => {
        resultsContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, 100);
}

/**
 * 更新nomogram可视化
 * @param {Object} params - 患者参数
 * @param {Object} results - 计算结果
 */
function updateVisualization(params, results) {
    // 初始化可视化器
    if (!visualizer) {
        visualizer = new window.NomogramVisualizer('nomogram-canvas');
    }

    // 更新图表
    try {
        console.log('更新nomogram可视化...', params, results);
        visualizer.update(params, results);
        console.log('nomogram可视化更新成功');
    } catch (error) {
        console.error('可视化更新失败:', error);
        // 不显示错误给用户，因为可视化是可选功能
    }
}

/**
 * 处理表单提交
 * @param {Event} event - 表单提交事件
 */
async function handleFormSubmit(event) {
    event.preventDefault();

    try {
        // 解析表单数据
        const params = window.NomogramCalculator.parseFormData(form);

        // 调试信息
        console.log('Parsed form data:', params);

        // 验证输入数据
        const validation = window.NomogramCalculator.validateInput(params);
        console.log('Validation result:', validation);
        if (!validation.isValid) {
            showError(validation.errors.join('\n'));
            return;
        }

        // 显示加载状态
        setLoading(true);

        // 模拟计算延迟，提供更好的用户体验
        await new Promise(resolve => setTimeout(resolve, 500));

        // 执行nomogram计算
        const results = window.NomogramCalculator.calculateNomogram(params);

        // 更新结果显示
        updateResults(results, params);

        // 更新nomogram可视化
        updateVisualization(params, results);

        // 记录使用情况（可选）
        console.log('Nomogram calculation completed:', {
            params,
            linearPredictor: results.linearPredictor,
            riskScore: results.riskScore
        });

    } catch (error) {
        console.error('计算错误:', error);
        showError('计算过程中发生错误，请重试。\n\n' + error.message);
    } finally {
        setLoading(false);
    }
}

/**
 * 实时验证输入
 * @param {HTMLInputElement} input - 输入元素
 */
function validateInputField(input) {
    const value = parseFloat(input.value);
    const isValid = !isNaN(value) && value >= parseFloat(input.min) && value <= parseFloat(input.max);

    if (isValid) {
        input.style.borderColor = '#4caf50';
    } else if (value) {
        input.style.borderColor = '#f44336';
    } else {
        input.style.borderColor = '#e1e1e1';
    }
}

/**
 * 初始化实时验证
 */
function initRealtimeValidation() {
    const inputs = form.querySelectorAll('input[type="number"]');
    inputs.forEach(input => {
        input.addEventListener('input', () => validateInputField(input));
        input.addEventListener('blur', () => validateInputField(input));
    });

    const selects = form.querySelectorAll('select');
    selects.forEach(select => {
        select.addEventListener('change', () => {
            select.style.borderColor = '#4caf50';
        });
    });
}

/**
 * 初始化PWA功能
 */
function initPWA() {
    // 检查是否支持PWA
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('/sw.js')
            .then(() => console.log('Service Worker registered'))
            .catch(error => console.log('Service Worker registration failed:', error));
    }

    // 应用安装提示
    let deferredPrompt;
    window.addEventListener('beforeinstallprompt', (e) => {
        e.preventDefault();
        deferredPrompt = e;

        // 显示安装提示（可选）
        const installPrompt = document.createElement('div');
        installPrompt.className = 'install-prompt';
        installPrompt.innerHTML = `
            📱 将此应用添加到主屏幕，方便离线使用！
            <button id="install-btn">安装</button>
        `;

        form.parentNode.insertBefore(installPrompt, form);

        document.getElementById('install-btn').addEventListener('click', () => {
            deferredPrompt.prompt();
            deferredPrompt.userChoice.then(() => {
                installPrompt.remove();
                deferredPrompt = null;
            });
        });
    });
}

/**
 * 初始化应用
 */
function initApp() {
    // 绑定表单提交事件
    form.addEventListener('submit', handleFormSubmit);

    // 初始化实时验证
    initRealtimeValidation();

    // 初始化PWA功能
    initPWA();

    // 添加键盘快捷键支持
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Enter' && event.ctrlKey) {
            form.dispatchEvent(new Event('submit'));
        }
    });

    console.log('Nomogram App initialized successfully');
}

/**
 * 添加生存率颜色样式
 */
function addSurvivalColorStyles() {
    const style = document.createElement('style');
    style.textContent = `
        .result-value.high { color: #4caf50; }
        .result-value.medium { color: #ff9800; }
        .result-value.low { color: #f44336; }

        .result-card {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .result-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
        }

        input:valid {
            border-color: #4caf50;
        }

        input:invalid:not(:placeholder-shown) {
            border-color: #f44336;
        }
    `;
    document.head.appendChild(style);
}

/**
 * 添加使用说明
 */
function addUsageTips() {
    const tips = [
        '请输入患者的临床数据',
        '所有字段都是必填项',
        '计算结果仅供参考',
        '请结合临床综合判断'
    ];

    // 可以在这里添加使用提示功能
}

// 页面加载完成后初始化应用
document.addEventListener('DOMContentLoaded', () => {
    addSurvivalColorStyles();
    initApp();

    // 添加加载完成的视觉反馈
    document.body.style.opacity = '0';
    setTimeout(() => {
        document.body.style.transition = 'opacity 0.5s ease';
        document.body.style.opacity = '1';
    }, 100);
});

// 错误处理
window.addEventListener('error', (event) => {
    console.error('Global error:', event.error);
    showError('应用发生错误，请刷新页面重试。');
});

// 导出一些函数用于调试
window.AppUtils = {
    setLoading,
    showError,
    updateResults
};