/**
 * CSV Export Module - CSV导出和历史记录管理
 * 完全离线运行，使用localStorage保存历史记录
 */

class CSVExportManager {
    constructor() {
        this.storageKey = 'nomogram_history';
        this.currentRecord = null;
    }

    /**
     * 保存当前记录到历史
     * @param {Object} params - 患者参数
     * @param {Object} results - 计算结果
     */
    saveRecord(params, results) {
        const record = {
            timestamp: new Date().toISOString(),
            date: new Date().toLocaleString('zh-CN', { 
                year: 'numeric', 
                month: '2-digit', 
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            }),
            params: params,
            results: results
        };

        this.currentRecord = record;

        // 获取历史记录
        const history = this.getHistory();
        history.push(record);

        // 保存到localStorage
        try {
            localStorage.setItem(this.storageKey, JSON.stringify(history));
            console.log('记录已保存到历史');
            this.updateHistoryCount();
            return true;
        } catch (error) {
            console.error('保存记录失败:', error);
            alert('保存记录失败：存储空间可能已满');
            return false;
        }
    }

    /**
     * 获取所有历史记录
     * @returns {Array} 历史记录数组
     */
    getHistory() {
        try {
            const data = localStorage.getItem(this.storageKey);
            return data ? JSON.parse(data) : [];
        } catch (error) {
            console.error('读取历史记录失败:', error);
            return [];
        }
    }

    /**
     * 清空历史记录
     */
    clearHistory() {
        if (confirm('确定要清空所有历史记录吗？此操作不可恢复。')) {
            localStorage.removeItem(this.storageKey);
            this.updateHistoryCount();
            alert('历史记录已清空');
            console.log('历史记录已清空');
        }
    }

    /**
     * 更新历史记录数量显示
     */
    updateHistoryCount() {
        const count = this.getHistory().length;
        const countElement = document.getElementById('history-count');
        if (countElement) {
            countElement.textContent = count;
        }
    }

    /**
     * 将记录转换为CSV格式
     * @param {Array} records - 记录数组
     * @returns {string} CSV字符串
     */
    recordsToCSV(records) {
        if (records.length === 0) {
            return '';
        }

        // CSV头部
        const headers = [
            '记录时间',
            '年龄(岁)',
            '性别',
            '胆红素(mg/dL)',
            '铜(μg/dL)',
            '疾病分期',
            '治疗方案',
            '2年生存率(%)',
            '5年生存率(%)',
            '8年生存率(%)',
            '风险评分',
            '线性预测值'
        ];

        // 转换数据行
        const rows = records.map(record => {
            const p = record.params;
            const r = record.results;

            // 性别转换
            const sex = p.sex === 'm' ? '男性' : '女性';

            // 治疗方案转换
            const trtMap = {
                '0': '对照组',
                '1': '治疗1',
                '2': '治疗2'
            };
            const trt = trtMap[p.trt] || p.trt;

            return [
                record.date,
                p.age,
                sex,
                p.bili,
                p.copper,
                p.stage,
                trt,
                (r.survivals['2y'] * 100).toFixed(2),
                (r.survivals['5y'] * 100).toFixed(2),
                (r.survivals['8y'] * 100).toFixed(2),
                r.riskScore.toFixed(4),
                r.linearPredictor.toFixed(4)
            ];
        });

        // 组合CSV
        const csvContent = [
            headers.join(','),
            ...rows.map(row => row.join(','))
        ].join('\n');

        return csvContent;
    }

    /**
     * 下载CSV文件
     * @param {string} csvContent - CSV内容
     * @param {string} filename - 文件名
     */
    downloadCSV(csvContent, filename) {
        // 添加BOM以支持Excel正确显示中文
        const BOM = '\uFEFF';
        const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);

        // 创建下载链接
        const link = document.createElement('a');
        link.href = url;
        link.download = filename;
        link.style.display = 'none';

        // 触发下载
        document.body.appendChild(link);
        link.click();

        // 清理
        setTimeout(() => {
            document.body.removeChild(link);
            URL.revokeObjectURL(url);
        }, 100);

        console.log('CSV文件已下载:', filename);
    }

    /**
     * 导出当前记录
     */
    exportCurrent() {
        if (!this.currentRecord) {
            alert('请先进行计算以生成记录');
            return;
        }

        const csv = this.recordsToCSV([this.currentRecord]);
        if (csv) {
            const filename = `nomogram_记录_${this.formatFilenameDate(new Date())}.csv`;
            this.downloadCSV(csv, filename);
            alert('当前记录已导出到CSV文件');
        }
    }

    /**
     * 导出所有历史记录
     */
    exportAll() {
        const history = this.getHistory();
        
        if (history.length === 0) {
            alert('没有历史记录可导出');
            return;
        }

        const csv = this.recordsToCSV(history);
        if (csv) {
            const filename = `nomogram_历史记录_${this.formatFilenameDate(new Date())}.csv`;
            this.downloadCSV(csv, filename);
            alert(`已导出 ${history.length} 条历史记录`);
        }
    }

    /**
     * 格式化文件名日期
     * @param {Date} date - 日期对象
     * @returns {string} 格式化的日期字符串
     */
    formatFilenameDate(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hour = String(date.getHours()).padStart(2, '0');
        const minute = String(date.getMinutes()).padStart(2, '0');
        const second = String(date.getSeconds()).padStart(2, '0');
        return `${year}${month}${day}_${hour}${minute}${second}`;
    }
}

// 创建全局实例
window.CSVExportManager = new CSVExportManager();

// 页面加载时初始化历史记录计数
document.addEventListener('DOMContentLoaded', () => {
    window.CSVExportManager.updateHistoryCount();
    console.log('CSV Export Manager initialized');
});

