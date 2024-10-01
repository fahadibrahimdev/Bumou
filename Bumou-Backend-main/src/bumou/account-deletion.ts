export const englishAccountDeletion = `<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Account Deletion</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 20px;
      }

      h1,
      h2,
      h3 {
        color: #333;
      }

      p {
        line-height: 1.6;
        color: #666;
      }

      a {
        color: #007bff;
        text-decoration: none;
      }

      a:hover {
        text-decoration: underline;
      }
      #languageDropdown {
        margin-bottom: 10px;
      }
    </style>
  </head>
  <body>
    <label for="languageDropdown">Language：</label>
    <select id="languageDropdown" onchange="changeLanguage(this.value)">
      <option value="en" selected>🇬🇧 English</option>
      <option value="zh">🇨🇳 中文</option>
    </select>
    <h1>Account Deletion for Bumou (咘呣) App</h1>

    <h2>1. Introduction:</h2>
    <p>
        This guide details the process for users to delete their account from the Bumou (咘呣) app. Our users’ privacy is critically important, and we provide an approachable means for account deletion.
    </p>

    <h2>2. Steps for Account Deletion:</h2>
    <ol>
        <li>Open the Your App Name app on your device.</li>
        <li>Go to your profile by tapping the profile icon.</li>
        <li>Access the drawer menu by tapping the menu icon.</li>
        <li>Select the "Delete Account" option.</li>
        <li>Confirm your account deletion as prompted. Note: Deletion is permanent, and all data will be lost.</li>
    </ol>

    <h2>3. Contact Information for Account Deletion Requests:</h2>
    <p>If you need assistance with deleting your account or would prefer to request account deletion via direct communication, please use the following contact details:</p>
    <ul>
        <li>Email: <a href="mailto:273219010@qq.com">273219010@qq.com</a></li>
        <li>Phone: +8618201840625</li>
    </ul>
    <p>
        We are here to help from Monday to Friday, 9 AM to 5 PM (Beijing Time). Provide us with your registered email address or username to help us identify and delete your account.
    </p>

    <h2>4. Developer Contact:</h2>
    <p>If you require further support, please reach out to our developer:</p>
    <ul>
        <li>Name: Jing Yang</li>
        <li>Company: 上海旭修信息技术有限公司</li>
        <li>Email: <a href="mailto:273219010@qq.com">273219010@qq.com</a></li>
        <li>Phone: +8618201840625</li>
        <li>Address: 中国上海市奉贤区海湾镇五四公路4399号37幢1479室, Postal Code: 221100</li>
    </ul>

    <p>We value your experience with Your App Name app and are dedicated to your privacy and satisfaction.</p>

    <script>
      function changeLanguage(selectedLanguage) {
        // Define the language-specific URLs
        const languageUrls = {
          en: window.location.href.split('?')[0] + '?lang=en',
          zh: window.location.href.split('?')[0] + '?lang=zh',
        };

        window.location.href = languageUrls[selectedLanguage];
      }
    </script>
  </body>
</html>`;

export const chineseAccountDeletion = `
        <!DOCTYPE html>
        <html lang="zh">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>账户删除指南 - Bumou (咘呣) 应用程序</title>
            <style>
            body {
                font-family: Arial, sans-serif;
                margin: 20px;
            }
    
            h1, h2, h3 {
                color: #333;
            }
    
            p {
                line-height: 1.6;
                color: #666;
            }
    
            a {
                color: #007bff;
                text-decoration: none;
            }
    
            a:hover {
                text-decoration: underline;
            }
            #languageDropdown {
                margin-bottom: 10px;
            }
            </style>
        </head>
        <body>
        <label for="languageDropdown">选择语言：</label>
        <select id="languageDropdown" onchange="changeLanguage(this.value)">
            <option value="en">🇬🇧 English</option>
            <option value="zh" selected>🇨🇳 中文</option>
        </select>
        <h1>Bumou (咘呣) 应用程序账户删除</h1>

    <h2>1. 介绍：</h2>
    <p>
        本指南详细说明了用户如何从Bumou (咘呣)应用程序中删除他们的账户。我们非常重视用户的隐私，因此提供简便的账户删除流程。
    </p>

    <h2>2. 删除账户的步骤：</h2>
    <ol>
        <li>在您的设备上打开Bumou (咘呣)应用程序。</li>
        <li>点击个人资料图标进入您的个人资料。</li>
        <li>点击菜单图标来访问抽屉菜单。</li>
        <li>选择"删除账户"选项。</li>
        <li>按照提示确认您的账户删除。请注意：删除操作是不可逆的，所有数据将被永久删除。</li>
    </ol>

    <h2>3. 账户删除请求的联系信息：</h2>
    <p>如果您在删除账户时遇到任何问题，或者更希望通过直接沟通来请求删除账户，请使用以下联系方式：</p>
    <ul>
        <li>电子邮件：<a href="mailto:273219010@qq.com">273219010@qq.com</a></li>
        <li>电话：+8618201840625</li>
    </ul>
    <p>
        我们的工作时间为周一至周五，上午9点至下午5点（北京时间）。请提供您注册时使用的电子邮件地址或用户名，以便我们帮助您识别并删除账户。
    </p>

    <h2>4. 开发者联系方式：</h2>
    <p>如果您需要进一步的帮助，请联系我们的开发者：</p>
    <ul>
        <li>姓名：Jing Yang</li>
        <li>公司：上海旭修信息技术有限公司</li>
        <li>电子邮件：<a href="mailto:273219010@qq.com">273219010@qq.com</a></li>
        <li>电话：+8618201840625</li>
        <li>地址：中国上海市奉贤区海湾镇五四公路4399号37幢1479室, 邮政编码：221100</li>
    </ul>

    <p>我们感谢您使用Bumou (咘呣)应用程序，并致力于为所有用户提供安全愉悦的体验。</p>
    
    <script>
        function changeLanguage(selectedLanguage) {
            // Define the language-specific URLs
            const languageUrls = {
                'en': window.location.href.split('?')[0]+ '?lang=en', 
                'zh': window.location.href.split('?')[0]+ '?lang=zh'};

            // Redirect to the selected language URL
            window.location.href = languageUrls[selectedLanguage];
        }
    </script>

</body>
</html>

`;
