export const englishPrivacy = `<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Privacy Policy</title>
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
    <h1>Privacy Policy for Bumou (咘呣) App</h1>
    <p>Last updated: April, 25 2024</p>
    <p>Effective date: April, 1 2024</p>

    <h2>1. Introduction:</h2>
    <p>
      Welcome to the Bumou (咘呣) App. We commit to protecting the privacy of
      our users, which includes students, teachers, and adults. Our Privacy
      Policy describes how we collect, use, store, and protect the personal
      information of our users.
    </p>

    <h2>2. Developer and Company Information:</h2>
    <p>Name: Jing Yang</p>
    <p>Company: 上海旭修信息技术有限公司</p>
    <p>Email: <a href="mailto:273219010@qq.com">273219010@qq.com</a></p>
    <p>Phone: +8618201840625</p>
    <p>
      Address: 中国上海市奉贤区海湾镇五四公路4399号37幢1479室, Postal Code:
      221100
    </p>

    <h2>3. Information Collection and Usage:</h2>
    <p>We collect the following types of information:</p>
    <ul>
      <li>
        <strong>Identification Data:</strong> Full name, email address,
        username, date of birth.
      </li>
      <li><strong>Contact Data:</strong> Phone number.</li>
      <li><strong>Content Data:</strong> Images, videos, and audio content.</li>
      <li><strong>Device Data:</strong> IP address, DeviceID.</li>
      <li>
        <strong>Usage Data:</strong> App interaction data, mood tracking
        entries.
      </li>
    </ul>
    <p>
      Each piece of data is actively provided by users. We do not collect any
      information automatically without user consent.
    </p>

    <h2>4. Purpose of Data Processing:</h2>
    <p>The data we collect is used for the following purposes:</p>
    <ul>
      <li>To create and manage user accounts.</li>
      <li>To facilitate social connections and communication.</li>
      <li>To enable mood tracking functionalities.</li>
      <li>To operate the emergency help feature.</li>
    </ul>

    <h2>5. Data Sharing and Disclosure:</h2>
    <p>
      Personal information is not shared with third parties, nor is it used for
      marketing. We store all data within AWS China, in compliance with Chinese
      data protection laws. Disclosure only occurs when required by Chinese law,
      under legal processes, or government requests.
    </p>
    <h2>6. User Consent and Rights:</h2>
    <p>
      By creating an account or using Bumou (咘呣), you consent to this Privacy
      Policy. Users have the right to: 
      <ul>
        <li>Access their personal information.</li>
        <li>Update or correct their information.</li>
        <li>Request deletion of their data or account.</li>
      </ul>
    </p>
    <h2>7. Data Security:</h2>
    <p>We adopt industry-standard security measures to protect personal information against unauthorized access, alteration, disclosure, or destruction. Despite our efforts, no security measures are entirely impenetrable.</p>
    <h2>8. Data Storage and Transfer:</h2>
    <p>Data resides exclusively within secure servers of AWS China, with no international transfer. This complies with regulations regarding data sovereignty within the People's Republic of China.</p>

    <h2>9. Children’s Privacy:</h2>
    <p>
      We recognize the importance of protecting children's personal information.
      The app requires:
    </p>
    <ul>
      <li>
        Users to input their date of birth upon registration for age
        verification.
      </li>
      <li>Parental consent for users under the age of 14.</li>
    </ul>

    <h2>10. Updates to This Policy:</h2>
    <p>We reserve the right to modify this Privacy Policy at any time. Any changes will be communicated to users via in-app notifications, phone, or email. Users will be required to give new consent for additional data processing activities not covered by the previous policy.</p>

    <h2>11. Contact Us:</h2>
    <p>For further questions regarding this Privacy Policy, please contact us using the information provided above.</p>

    <h2>12. Self-starting and Related Launches:</h2>
<p>
  To ensure that Bumou (咘呣) can receive broadcast messages such as push notifications when the app is closed or running in the background, we utilize self-start capabilities. This may involve the app waking up periodically through system broadcasts to enable the receipt of push notifications or to restore a previous state. These actions are strictly necessary to render the app's functionalities and services effectively.
</p>
<p>
  If you open a content-based push notification, with your explicit consent, the app will redirect you to the related content. Without your consent, the app will not initiate any related launch.
</p>

<h2>13. Push Notifications:</h2>
<p>
  Push notifications are used to improve your experience with Bumou (咘呣) by keeping you informed about chat messages and help requests, even when the app is not actively in use. To receive these notifications, our app may require to self-start or be woken by a system broadcast designed for this purpose. Your consent will be sought before enabling push notifications and can be configured via the app settings or your device's notification settings.
</p>

<h2>14. Download Management:</h2>
<p>
  In-app downloads, such as update packages, are managed carefully. Our app processes the HTTP connection, monitors changes in status during downloads, and handles system restart scenarios to ensure downloads are completed. This may entail the app's background processes self-starting to continue downloads while you are using other apps or after the device restarts. When a download is completed, our app aids in acquiring the APK file for installation.
</p>

<h2>15. Widgets:</h2>
<p>
  For users who take advantage of Bumou (咘呣)'s desktop widget features, our app needs to listen for system broadcasts (android.appwidget.action.APPWIDGET_UPDATE) to refresh the widget's content. This system broadcast dictates whether an update is necessary; our app's self-start capabilities may be used to wake up the necessary services to update the widget data.
</p>
<br>
<p>Effective date: April, 1 2024 - Last updated: April, 25 2024</p>

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

export const chinesePrivacy = `
        <!DOCTYPE html>
        <html lang="zh">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>隐私政策</title>
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
        <h1>咘呣App隐私政策</h1>

        <p>生效日期：2024年4月1日 - 最后更新日期：2024年4月25日</p>

<h2>1. 引言：</h2>
<p>
  欢迎使用咘呣App。我们致力于保护用户的隐私，包括学生、教师和成人。我们的隐私政策描述了我们如何收集、使用、存储以及保护用户的个人信息。
</p>

<h2>2. 开发者及公司信息：</h2>
<p>姓名：杨静</p>
<p>公司: 上海旭修信息技术有限公司</p>
<p>电子邮箱：<a href="mailto:273219010@qq.com">273219010@qq.com</a></p>
<p>电话：+8618201840625</p>
<p>
  地址：中国上海市奉贤区海湾镇五四公路4399号37幢1479室, 邮政编码：221100
</p>

<h2>3. 信息的收集与使用：</h2>
<p>我们收集以下类型的信息：</p>
<ul>
  <li>
    <strong>身份数据：</strong>全名、电子邮件地址、用户名、出生日期。
  </li>
  <li><strong>联系方式：</strong>电话号码。</li>
  <li><strong>内容数据：</strong>图像、视频和音频内容。</li>
  <li><strong>设备数据：</strong>IP地址、设备标识符。</li>
  <li>
    <strong>使用数据：</strong>App互动数据，情绪跟踪记录。
  </li>
</ul>
<p>
  这些数据都是由用户主动提供的。未经用户同意，我们不会自动收集任何信息。
</p>

<h2>4. 数据处理的目的：</h2>
<p>我们收集的数据用于以下目的：</p>
<ul>
  <li>创建和管理用户账户。</li>
  <li>促进社交联系和沟通。</li>
  <li>开启情绪跟踪功能。</li>
  <li>运营紧急求助功能。</li>
</ul>

<h2>5. 数据分享和披露：</h2>
<p>
  个人信息不会与第三方共享，也不会用于营销。我们将所有数据存储在AWS中国的合规数据中心里。只有在中国法律、法律程序或政府要求的情况下才会披露信息。
</p>
<h2>6. 用户同意和权利：</h2>
<p>
  通过创建账户或使用咘呣App，即表示您同意本隐私政策。用户有权利：
  <ul>
    <li>访问他们的个人信息。</li>
    <li>更新或更正自己的信息。</li>
    <li>请求删除他们的数据或账户。</li>
  </ul>
</p>
<h2>7. 数据安全：</h2>
<p>我们采用行业标准的安全措施来保护个人信息不受未授权的访问、更改、披露或破坏。尽管如此，没有任何安全措施是完全无法渗透的。</p>
<h2>8. 数据存储与转移：</h2>
<p>数据专属存储在中国AWS的安全服务器中，不会进行国际传输。这符合中华人民共和国有关数据主权的法规。</p>

<h2>9. 儿童隐私：</h2>
<p>
  我们认识到保护儿童个人信息的重要性。该应用程序要求：
</p>
<ul>
  <li>
    用户在注册时输入出生日期以验证年龄。
  </li>
  <li>14岁以下用户的家长同意。</li>
</ul>

<h2>10. 本政策的更新：</h2>
<p>我们保留随时修改本隐私政策的权利。任何更改将通过应用内通知、电话或电子邮件通知给用户。用户将需要对此前政策未涵盖的额外数据处理活动给予新的同意。</p>

<h2>11. 联系我们：</h2>
<p>如有任何关于本隐私政策的疑问，请使用上述提供的信息联系我们。</p>

<h2>12. 自动启动及相关启动说明：</h2>
<p>
  为了保证Bumou (咘呣) 应用在关闭或后台运行状态下，仍能正常接收到客户端推送的信息，我们会利用自动启动功能。这可能涉及应用通过系统广播定期唤醒。这些操作是为了有效提供应用功能和服务而绝对必要的。
</p>
<p>
  如果您打开了基于内容的推送消息，在获得您的明确同意后，应用将引导您跳转到相关内容。未经您的同意，我们不会启动任何相关的应用程序。
</p>

<h2>13. 推送通知：</h2>
<p>
  推送通知用于通过及时告知聊天消息和帮助请求，来提升您使用Bumou (咘呣) 的体验，即使在应用程序不在使用中。为了接收这些通知，我们的应用可能需要自启或被系统广播唤醒以实现此目的。在启用推送通知前，我们会征求您的同意，您也可以通过应用设置或设备的通知设置进行配置。
</p>

<h2>14. 下载管理：</h2>
<p>
  应用内下载（比如更新包）会被仔细管理。我们的应用会处理HTTP连接、监控下载过程中的状态变化，并在系统重启场景下确保下载的完成。这可能需要应用的后台进程自动启动以在您使用其他应用或设备重启后继续下载。下载完成后，我们的应用会协助获取APK文件进行安装。
</p>

<h2>15. 小组件：</h2>
<p>
  对于使用Bumou (咘呣) 桌面小组件功能的用户，我们的应用需要监听系统广播（android.appwidget.action.APPWIDGET_UPDATE），以刷新小组件的内容。这个系统广播会指示是否需要更新；我们的应用的自动启动功能可能会被用来唤醒必要的服务来更新小组件数据。
</p>

<br>
<p>生效日期：2024年4月1日 - 最后更新日期：2024年4月25日</p>

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
