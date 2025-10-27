/**
 * iOS/iPhone 特定功能增强
 * 处理PWA安装提示、触摸优化、iOS特定交互等
 */

// iOS设备检测
const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) ||
              (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);

const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);

const isStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                    window.navigator.standalone === true;

/**
 * iOS设备信息和优化设置
 */
const iOSOptimization = {
    isIOS,
    isSafari,
    isStandalone,
    hasNotch: false,

    // 检测iPhone型号和刘海屏
    detectDevice() {
        const ratio = window.devicePixelRatio || 1;
        const width = window.screen.width;
        const height = window.screen.height;

        // iPhone X及更新机型通常有刘海屏
        if (isIOS && height >= 812 && ratio >= 2) {
            this.hasNotch = true;
        }

        console.log('iOS设备检测:', {
            isIOS: this.isIOS,
            isSafari: this.isSafari,
            isStandalone: this.isStandalone,
            hasNotch: this.hasNotch,
            screenWidth: width,
            screenHeight: height,
            pixelRatio: ratio
        });
    },

    // 防止iOS缩放
    preventZoom() {
        if (isIOS) {
            const viewport = document.querySelector('meta[name="viewport"]');
            if (viewport) {
                viewport.setAttribute('content',
                    'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover');
            }
        }
    },

    // 优化触摸体验
    optimizeTouch() {
        if (isIOS) {
            // 为按钮添加触摸反馈
            const buttons = document.querySelectorAll('button, .btn, input[type="button"]');
            buttons.forEach(button => {
                button.addEventListener('touchstart', function() {
                    this.style.transform = 'scale(0.98)';
                });

                button.addEventListener('touchend', function() {
                    this.style.transform = 'scale(1)';
                });
            });

            // 防止双击缩放
            let lastTouchEnd = 0;
            document.addEventListener('touchend', function(event) {
                const now = Date.now();
                if (now - lastTouchEnd <= 300) {
                    event.preventDefault();
                }
                lastTouchEnd = now;
            }, false);
        }
    },

    // 优化输入框体验
    optimizeInputs() {
        if (isIOS) {
            const inputs = document.querySelectorAll('input[type="number"]');
            inputs.forEach(input => {
                // 设置输入模式，优化键盘显示
                input.setAttribute('inputmode', 'decimal');

                // 防止iOS自动放大
                if (parseFloat(window.getComputedStyle(input).fontSize) < 16) {
                    input.style.fontSize = '16px';
                }

                // 优化焦点体验
                input.addEventListener('focus', function() {
                    this.scrollIntoView({ behavior: 'smooth', block: 'center' });
                });
            });
        }
    },

    // 安装提示管理
    installPrompt: null,
    deferredPrompt: null,

    // 显示安装提示
    showInstallPrompt() {
        if (isIOS && isSafari && !isStandalone) {
            // iOS Safari安装提示
            this.showIOSInstallPrompt();
        } else if (this.deferredPrompt && !isStandalone) {
            // 其他浏览器的PWA安装提示
            this.showPWAInstallPrompt();
        }
    },

    // iOS Safari安装提示
    showIOSInstallPrompt() {
        // 检查是否已经显示过提示
        if (localStorage.getItem('ios-install-prompt-shown')) {
            return;
        }

        const prompt = document.createElement('div');
        prompt.className = 'ios-install-prompt';
        prompt.innerHTML = `
            <div class="prompt-content">
                <div class="prompt-icon">📱</div>
                <div class="prompt-text">
                    <strong>添加到主屏幕</strong>
                    <p>点击分享按钮，然后选择"添加到主屏幕"</p>
                </div>
                <button class="prompt-close" onclick="this.parentElement.parentElement.remove()">×</button>
            </div>
        `;

        // 添加样式
        const style = document.createElement('style');
        style.textContent = `
            .ios-install-prompt {
                position: fixed;
                bottom: 20px;
                left: 20px;
                right: 20px;
                background: #2196f3;
                color: white;
                border-radius: 12px;
                padding: 15px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.3);
                z-index: 1000;
                animation: slideUp 0.3s ease;
            }

            .prompt-content {
                display: flex;
                align-items: center;
                position: relative;
            }

            .prompt-icon {
                font-size: 24px;
                margin-right: 12px;
            }

            .prompt-text {
                flex: 1;
            }

            .prompt-text strong {
                display: block;
                margin-bottom: 4px;
            }

            .prompt-text p {
                margin: 0;
                font-size: 14px;
                opacity: 0.9;
            }

            .prompt-close {
                position: absolute;
                top: -5px;
                right: -5px;
                background: rgba(255,255,255,0.2);
                border: none;
                color: white;
                border-radius: 50%;
                width: 24px;
                height: 24px;
                font-size: 16px;
                cursor: pointer;
            }

            @keyframes slideUp {
                from { transform: translateY(100%); opacity: 0; }
                to { transform: translateY(0); opacity: 1; }
            }
        `;

        document.head.appendChild(style);
        document.body.appendChild(prompt);

        // 标记已显示过
        localStorage.setItem('ios-install-prompt-shown', 'true');

        // 5秒后自动移除
        setTimeout(() => {
            if (prompt.parentElement) {
                prompt.remove();
                style.remove();
            }
        }, 8000);
    },

    // PWA安装提示 (Chrome等浏览器)
    showPWAInstallPrompt() {
        if (!this.deferredPrompt) return;

        this.deferredPrompt.prompt();
        this.deferredPrompt.userChoice.then((choiceResult) => {
            if (choiceResult.outcome === 'accepted') {
                console.log('用户接受了PWA安装');
            } else {
                console.log('用户拒绝了PWA安装');
            }
            this.deferredPrompt = null;
        });
    },

    // 监听PWA安装事件
    initPWAInstall() {
        window.addEventListener('beforeinstallprompt', (e) => {
            e.preventDefault();
            this.deferredPrompt = e;

            // 延迟显示安装提示
            setTimeout(() => {
                this.showInstallPrompt();
            }, 3000);
        });

        // 监听应用安装
        window.addEventListener('appinstalled', () => {
            console.log('PWA已成功安装');
            this.deferredPrompt = null;
        });
    },

    // 初始化所有iOS优化
    init() {
        this.detectDevice();
        this.preventZoom();
        this.optimizeTouch();
        this.optimizeInputs();
        this.initPWAInstall();

        // 延迟显示安装提示
        if (isIOS && !isStandalone) {
            setTimeout(() => {
                this.showInstallPrompt();
            }, 5000);
        }
    }
};

/**
 * 安全区域适配
 */
function setupSafeArea() {
    if (iOSOptimization.hasNotch) {
        document.documentElement.style.setProperty('--safe-area-inset-top', '44px');
        document.documentElement.style.setProperty('--safe-area-inset-bottom', '34px');
    }
}

/**
 * 全屏模式支持
 */
function requestFullscreen() {
    if (iOSOptimization.isIOS) {
        // iOS设备使用全屏API的替代方案
        if (document.documentElement.requestFullscreen) {
            document.documentElement.requestFullscreen();
        } else if (document.documentElement.webkitRequestFullscreen) {
            document.documentElement.webkitRequestFullscreen();
        } else if (document.documentElement.mozRequestFullScreen) {
            document.documentElement.mozRequestFullScreen();
        }
    }
}

/**
 * 页面可见性变化处理
 */
function handleVisibilityChange() {
    if (document.hidden) {
        // 页面隐藏时的处理
        console.log('应用已隐藏');
    } else {
        // 页面显示时的处理
        console.log('应用已显示');
        // 可以在这里刷新数据或重新计算
    }
}

/**
 * 初始化iOS增强功能
 */
function initIOSEnhancements() {
    // 等待DOM加载完成
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            iOSOptimization.init();
            setupSafeArea();
        });
    } else {
        iOSOptimization.init();
        setupSafeArea();
    }

    // 监听页面可见性变化
    document.addEventListener('visibilitychange', handleVisibilityChange);

    // 监听屏幕方向变化
    window.addEventListener('orientationchange', () => {
        setTimeout(() => {
            iOSOptimization.detectDevice();
            setupSafeArea();
        }, 100);
    });

    // 导出到全局作用域
    window.iOSOptimization = iOSOptimization;
    window.requestFullscreen = requestFullscreen;
}

// 启动iOS增强功能
initIOSEnhancements();