/**
 * Nomogram Visualization Module
 * 使用Canvas绘制简化的nomogram图表
 */

class NomogramVisualizer {
    constructor(canvasId) {
        this.canvas = document.getElementById(canvasId);
        this.ctx = this.canvas.getContext('2d');
        this.setupCanvas();
    }

    setupCanvas() {
        // 设置合适的Canvas尺寸
        const rect = this.canvas.getBoundingClientRect();

        // 设置实际绘图尺寸
        const dpr = window.devicePixelRatio || 1;

        // 根据屏幕尺寸调整
        const screenWidth = window.innerWidth;
        let minWidth, minHeight;

        if (screenWidth < 480) {
            minWidth = 280;
            minHeight = 350;
        } else if (screenWidth < 768) {
            minWidth = 350;
            minHeight = 300;
        } else {
            minWidth = Math.max(rect.width, 400);
            minHeight = Math.max(rect.height, 350);
        }

        this.canvas.width = minWidth * dpr;
        this.canvas.height = minHeight * dpr;

        this.ctx.scale(dpr, dpr);

        // 设置实际显示尺寸
        this.canvas.style.width = minWidth + 'px';
        this.canvas.style.height = minHeight + 'px';

        this.width = minWidth;
        this.height = minHeight;
    }

    /**
     * 绘制nomogram图表
     * @param {Object} params - 患者参数
     * @param {Object} results - 计算结果
     */
    drawNomogram(params, results) {
        // 清空画布
        this.ctx.clearRect(0, 0, this.width, this.height);

        // 设置样式
        this.ctx.font = '12px Inter, sans-serif';
        this.ctx.textAlign = 'center';

        // 计算各个变量的点数
        const variables = this.calculatePoints(params);

        // 绘制各个变量的标尺
        const variablesList = [
            { name: '年龄', param: 'age', value: params.age, points: variables.age, range: [0, 120] },
            { name: '胆红素', param: 'bili', value: params.bili, points: variables.bili, range: [0, 20] },
            { name: '铜', param: 'copper', value: params.copper, points: variables.copper, range: [0, 500] },
            { name: '分期', param: 'stage', value: params.stage, points: variables.stage, range: [1, 4] },
            { name: '总分', param: 'total', value: results.linearPredictor.toFixed(2), points: this.calculateTotalPoints(variables), range: [0, 300] }
        ];

        this.drawVariables(variablesList);
        this.drawSurvivalAxis(results);
        this.drawConnections(variablesList, results);
    }

    /**
     * 计算各变量的点数
     * @param {Object} params - 患者参数
     * @returns {Object} 各变量的点数
     */
    calculatePoints(params) {
        const coeffs = window.NomogramCalculator.COEFFICIENTS;

        // 简化的点数计算（基于系数比例）
        const points = {
            age: params.age * 2, // 简化计算
            bili: this.getBilirubinPoints(params.bili),
            copper: params.copper * 0.1, // 简化计算
            stage: params.stage * 20 // 简化计算
        };

        return points;
    }

    getBilirubinPoints(bili) {
        if (bili <= 2) return bili * 5;
        if (bili <= 4) return 10 + (bili - 2) * 10;
        return 30 + (bili - 4) * 8;
    }

    calculateTotalPoints(variables) {
        return variables.age + variables.bili + variables.copper + variables.stage;
    }

    /**
     * 绘制变量标尺
     * @param {Array} variablesList - 变量列表
     */
    drawVariables(variablesList) {
        const isMobile = this.width < 480;
        const isTablet = this.width < 768;
        const margin = isMobile ? 25 : (isTablet ? 40 : 60);
        const scaleWidth = this.width - margin * 2;
        const scaleHeight = isMobile ? 25 : 35;
        const verticalSpacing = isMobile ? 45 : (isTablet ? 55 : 65);
        const startY = 35;

        variablesList.forEach((variable, index) => {
            const y = startY + index * verticalSpacing;

            // 绘制变量名称
            this.ctx.fillStyle = '#333';
            this.ctx.font = isMobile ? 'bold 12px Inter, sans-serif' : 'bold 14px Inter, sans-serif';
            this.ctx.textAlign = 'left';
            this.ctx.fillText(variable.name, 5, y + scaleHeight/2);

            // 绘制标尺线
            this.ctx.strokeStyle = '#ddd';
            this.ctx.lineWidth = 1;
            this.ctx.beginPath();
            this.ctx.moveTo(margin, y);
            this.ctx.lineTo(margin + scaleWidth, y);
            this.ctx.stroke();

            // 绘制刻度
            this.drawScale(margin, y, scaleWidth, variable.range, isMobile);

            // 标记当前值
            const valuePosition = this.valueToPosition(variable.value, variable.range, margin, scaleWidth);
            this.ctx.fillStyle = '#2196f3';
            this.ctx.beginPath();
            this.ctx.arc(valuePosition, y, isMobile ? 4 : 6, 0, 2 * Math.PI);
            this.ctx.fill();

            // 显示当前值
            this.ctx.fillStyle = '#666';
            this.ctx.font = isMobile ? '10px Inter, sans-serif' : '11px Inter, sans-serif';
            this.ctx.textAlign = 'center';
            this.ctx.fillText(variable.value.toString(), valuePosition, y - (isMobile ? 12 : 15));

            // 显示点数（移动端字体更小）
            if (variable.param !== 'total' && !isMobile) {
                this.ctx.fillStyle = '#ff9800';
                this.ctx.font = 'bold 12px Inter, sans-serif';
                this.ctx.textAlign = 'right';
                this.ctx.fillText(`${variable.points.toFixed(1)}分`, this.width - 10, y + scaleHeight/2 + 4);
            }
        });
    }

    /**
     * 绘制标尺刻度
     * @param {number} x - 起始x坐标
     * @param {number} y - y坐标
     * @param {number} width - 标尺宽度
     * @param {Array} range - 值范围
     */
    drawScale(x, y, width, range, isMobile = false) {
        const [min, max] = range;
        const tickCount = isMobile ? 3 : 5;

        this.ctx.strokeStyle = '#999';
        this.ctx.lineWidth = 1;
        this.ctx.fillStyle = '#666';
        this.ctx.font = isMobile ? '8px Inter, sans-serif' : '10px Inter, sans-serif';
        this.ctx.textAlign = 'center';

        for (let i = 0; i <= tickCount; i++) {
            const value = min + (max - min) * (i / tickCount);
            const tickX = x + (width * (i / tickCount));

            // 绘制刻度线
            this.ctx.beginPath();
            this.ctx.moveTo(tickX, y - (isMobile ? 3 : 5));
            this.ctx.lineTo(tickX, y + (isMobile ? 3 : 5));
            this.ctx.stroke();

            // 绘制刻度值
            this.ctx.fillText(value.toFixed(0), tickX, y + (isMobile ? 14 : 18));
        }
    }

    /**
     * 将值转换为标尺上的位置
     * @param {number} value - 值
     * @param {Array} range - 范围
     * @param {number} margin - 边距
     * @param {number} width - 标尺宽度
     * @returns {number} x坐标
     */
    valueToPosition(value, range, margin, width) {
        const [min, max] = range;
        const normalizedValue = (value - min) / (max - min);
        return margin + width * Math.max(0, Math.min(1, normalizedValue));
    }

    /**
     * 绘制生存率轴
     * @param {Object} results - 计算结果
     */
    drawSurvivalAxis(results) {
        const margin = 60;
        const scaleWidth = this.width - margin * 2;
        const y = this.height - 60;

        // 绘制生存率标题
        this.ctx.fillStyle = '#333';
        this.ctx.font = 'bold 14px Inter, sans-serif';
        this.ctx.textAlign = 'left';
        this.ctx.fillText('生存率', 10, y);

        // 绘制标尺线
        this.ctx.strokeStyle = '#2196f3';
        this.ctx.lineWidth = 3;
        this.ctx.beginPath();
        this.ctx.moveTo(margin, y);
        this.ctx.lineTo(margin + scaleWidth, y);
        this.ctx.stroke();

        // 绘制生存率刻度
        const survivalRates = [0, 0.25, 0.5, 0.75, 1.0];
        this.ctx.fillStyle = '#666';
        this.ctx.font = '10px Inter, sans-serif';
        this.ctx.textAlign = 'center';

        survivalRates.forEach(rate => {
            const x = margin + scaleWidth * (1 - rate); // 反向，因为高生存率在左边
            const percentage = (rate * 100).toFixed(0) + '%';

            // 绘制刻度线
            this.ctx.strokeStyle = '#999';
            this.ctx.lineWidth = 1;
            this.ctx.beginPath();
            this.ctx.moveTo(x, y - 8);
            this.ctx.lineTo(x, y + 8);
            this.ctx.stroke();

            // 绘制刻度值
            this.ctx.fillText(percentage, x, y + 22);
        });

        // 标记当前生存率
        const survivals = ['2y', '5y', '8y'];
        const colors = ['#4caf50', '#ff9800', '#f44336'];

        survivals.forEach((year, index) => {
            const survival = results.survivals[year];
            const x = margin + scaleWidth * (1 - survival);

            this.ctx.fillStyle = colors[index];
            this.ctx.beginPath();
            this.ctx.arc(x, y, 5, 0, 2 * Math.PI);
            this.ctx.fill();

            // 添加标签
            this.ctx.fillStyle = colors[index];
            this.ctx.font = '10px Inter, sans-serif';
            this.ctx.fillText(year, x, y - 12);
        });
    }

    /**
     * 绘制连接线
     * @param {Array} variablesList - 变量列表
     * @param {Object} results - 计算结果
     */
    drawConnections(variablesList, results) {
        const margin = 60;
        const scaleWidth = this.width - margin * 2;
        const verticalSpacing = 70;
        const startY = 40;

        // 绘制从总分到生存率的连接线
        const totalVariable = variablesList.find(v => v.param === 'total');
        if (totalVariable) {
            const totalX = this.valueToPosition(totalVariable.value, totalVariable.range, margin, scaleWidth);
            const totalY = startY + (variablesList.length - 1) * verticalSpacing;
            const survivalY = this.height - 60;

            // 绘制连接线
            this.ctx.strokeStyle = 'rgba(33, 150, 243, 0.3)';
            this.ctx.lineWidth = 2;
            this.ctx.setLineDash([5, 5]);
            this.ctx.beginPath();
            this.ctx.moveTo(totalX, totalY);
            this.ctx.lineTo(totalX, survivalY);
            this.ctx.stroke();
            this.ctx.setLineDash([]);
        }
    }

    /**
     * 更新图表
     * @param {Object} params - 患者参数
     * @param {Object} results - 计算结果
     */
    update(params, results) {
        this.setupCanvas(); // 重新设置canvas以响应窗口大小变化
        this.drawNomogram(params, results);
    }
}

// 导出类
window.NomogramVisualizer = NomogramVisualizer;