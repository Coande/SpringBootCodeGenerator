<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>SQL转Java JPA、MYBATIS实现类代码生成平台</title>
    <meta name="keywords" content="sql转实体类,sql转DAO,SQL转service,SQL转JPA实现,SQL转MYBATIS实现">

    <#import "common/common-import.ftl" as netCommon>
    <@netCommon.commonStyle />
    <@netCommon.commonScript />

    <style>
        <#-- 自定义样式 -->

        h4 {
            text-align: center;
        }

        .CodeMirror {
            border: 1px solid #eeeeee;
        }

        .jumbotron {
            padding: 2rem 1rem;
        }

        .input-group-text {
            color: #ffffff;
            background-color: #1890ff;
            border: none;
            border-top-left-radius: .25rem !important;
            border-bottom-left-radius: .25rem !important;
        }

        .input-group>.custom-select:not(:first-child), .input-group>.form-control:not(:first-child) {
            margin-right: 20px;
        }

        .input-group input,
        .input-group select {
            border-top-right-radius: .25rem !important;
            border-bottom-right-radius: .25rem !important;
        }

        .input-group input:last-of-type,
        .input-group select:last-of-type{
            margin-right: 0 !important;
        }

        .btn-primary.disabled, .btn-primary:disabled {
            background-color: #1890ff;
            opacity: 1;
        }

        #btnCopy {
            display: none;
            background-color: #ffffff;
        }

        .btn-secondary.disabled, .btn-secondary:disabled {
            background-color: #1890ff;
            border: none;
        }

        .bd-footer,
        .bd-footer a{
            font-size: 12px;
            color: #dedede !important;
            text-align: center;
        }
    </style>

<script>

    <@netCommon.viewerCounter />

    $(function () {
        /**
         * 初始化 table sql 3
         */
        var ddlSqlArea = CodeMirror.fromTextArea(document.getElementById("ddlSqlArea"), {
            lineNumbers: true,
            matchBrackets: true,
            mode: "text/x-sql",
            lineWrapping:false,
            readOnly:false,
            foldGutter: true,
            //keyMap:"sublime",
            gutters:["CodeMirror-linenumbers", "CodeMirror-foldgutter"]
        });
        ddlSqlArea.setSize('auto','auto');
        // controller_ide
        var genCodeArea = CodeMirror.fromTextArea(document.getElementById("genCodeArea"), {
            lineNumbers: true,
            matchBrackets: true,
            mode: "text/x-java",
            lineWrapping:true,
            readOnly:false,
            foldGutter: true,
            //keyMap:"sublime",
            gutters:["CodeMirror-linenumbers", "CodeMirror-foldgutter"]
        });
        genCodeArea.setSize('auto','auto');

        var codeData;
        // 使用：var jsonObj = $("#formId").serializeObject();
        $.fn.serializeObject = function()
        {
            var o = {};
            var a = this.serializeArray();
            $.each(a, function() {
                if (o[this.name]) {
                    if (!o[this.name].push) {
                        o[this.name] = [o[this.name]];
                    }
                    o[this.name].push(this.value || '');
                } else {
                    o[this.name] = this.value || '';
                }
            });
            return o;
        };
        var historyCount=0;
        //初始化清除session
        if (window.sessionStorage){
            //修复当F5刷新的时候，session没有清空各个值，但是页面的button没了。
            sessionStorage.clear();
        }
        /**
         * 生成代码
         */
        $('#btnGenCode').click(function ()  {
            var jsonData = {
                "tableSql": ddlSqlArea.getValue(),
                "packageName":$("#packageName").val(),
                "returnUtil":$("#returnUtil").val(),
                "authorName":$("#authorName").val(),
                "dataType":$("#dataType").val(),
                "tinyintTransType":$("#tinyintTransType").val(),
                "nameCaseType":$("#nameCaseType").val(),
                "swagger":$("#isSwagger").val()
            };
            $.ajax({
                type: 'POST',
                url: base_url + "/genCode",
                data:(JSON.stringify(jsonData)),
                dataType: "json",
                contentType: "application/json",
                success: function (data) {
                    if (data.code === 200) {
                        codeData = data.data;
                        genCodeArea.setValue(codeData.beetlentity);
                        genCodeArea.setSize('auto', 'auto');
                        $.toast("√ 代码生成成功");
                        //添加历史记录
                        addHistory(codeData);

                        // 显示复制按钮
                        // 如果是 http，获取不到 navigator.clipboard 对象，则不需要显示
                        if (navigator.clipboard) {
                            $("#btnCopy").show()
                        }

                    } else {
                        $.toast("× 代码生成失败 :"+data.msg);
                    }
                }
            });
            return false;
        });
        /**
         * 切换历史记录
         */
        function getHistory(tableName){
            if (window.sessionStorage){
                var valueSession = sessionStorage.getItem(tableName);
                codeData = JSON.parse(valueSession);
                $.toast("$ 切换历史记录成功:"+tableName);
                genCodeArea.setValue(codeData.entity);
            }else{
                console.log("浏览器不支持sessionStorage");
            }
        }
        /**
         * 添加历史记录
         */
        function addHistory(data){
            if (window.sessionStorage){
                //console.log(historyCount);
                if(historyCount>=9){
                    $("#history").find(".btn:last").remove();
                    historyCount--;
                }
                var tableName=data.tableName;
                var valueSession = sessionStorage.getItem(tableName);
                if(valueSession!==undefined && valueSession!=null){
                    sessionStorage.removeItem(tableName);
                }else{
                    $("#history").prepend('<button id="his-'+tableName+'" type="button" class="btn btn-light btn-sm">'+tableName+'</button>');
                    //$("#history").prepend('<button id="his-'+tableName+'" onclick="getHistory(\''+tableName+'\');" type="button" class="btn">'+tableName+'</button>');
                    $("#his-"+tableName).bind('click', function () {getHistory(tableName)});
                }
                sessionStorage.setItem(tableName,JSON.stringify(data));
                historyCount++;
            }else{
                console.log("浏览器不支持sessionStorage");
            }
        }

        /**
         * 按钮事件组
         */
        $('.generator').bind('click', function () {
            if (!$.isEmptyObject(codeData)) {
                var id = this.id;
                genCodeArea.setValue(codeData[id]);
                genCodeArea.setSize('auto', 'auto');
            }
        });
        /**
         * 捐赠
         */
        function donate(){
            if($("#donate").attr("show")=="no"){
                $("#donate").html('<img src="http://upyun.bejson.com/img/zhengkai.png"></img>');
                $("#donate").attr("show","yes");
            }else{
                $("#donate").html('<p>谢谢赞赏！</p>');
                $("#donate").attr("show","no");
            }
        }
        $('#donate1').on('click', function(){
            donate();
        });
        $('#donate2').on('click', function(){
            donate();
        });
        $('#btnCopy').on('click', function(){
            if(!$.isEmptyObject(genCodeArea.getValue())&&!$.isEmptyObject(navigator)&&!$.isEmptyObject(navigator.clipboard)){
                navigator.clipboard.writeText(genCodeArea.getValue());
                $.toast("√ 复制成功");
            }
        });

        function getVersion(){
            var gitVersion ;
            $.ajax({
                type: 'GET',
                url: "https://raw.githubusercontent.com/moshowgame/SpringBootCodeGenerator/master/generator-web/src/main/resources/static/version.json",
                dataType: "json",
                success: function (data) {
                    gitVersion = data.version;
                    $.ajax({
                        type: 'GET',
                        url: base_url + "/static/version.json",
                        dataType: "json",
                        success: function (data) {
                            $.toast("#当前版本:"+data.version+" | github:"+gitVersion);
                        }
                    });
                }
            });
        }
        $('#version').on('click', function(){
            getVersion();
        });
    });
</script>
</head>
<body>

<!-- Main jumbotron for a primary marketing message or call to action -->
<div class="jumbotron" style="background-color: #ffffff">
    <div class="container">
        <h4>Spring Boot 代码在线生成</h4><br>
        <textarea id="ddlSqlArea" placeholder="请输入表结构信息..." class="form-control btn-lg" style="height: 250px;">
CREATE TABLE 'userinfo' (
  'user_id' int(11) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  'username' varchar(255) NOT NULL COMMENT '用户名',
  'addtime' datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY ('user_id')
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户信息'
        </textarea><br>
        <div class="input-group mb-3">
            <div class="input-group-prepend">
                <span class="input-group-text">作者名称</span>
            </div>
            <input type="text" class="form-control" id="authorName" name="authorName" value="Coande">
            <div class="input-group-prepend">
                <span class="input-group-text">返回封装</span>
            </div>
            <input type="text" class="form-control" id="returnUtil" name="returnUtil" value="new ReturnT<>">
            <div class="input-group-prepend">
                <span class="input-group-text">包名路径</span>
            </div>
            <input type="text" class="form-control" id="packageName" name="packageName" value="com.e12e.system">
        </div>
        <div class="input-group mb-3">
            <div class="input-group-prepend">
                <span class="input-group-text">数据类型</span>
            </div>
            <select type="text" class="form-control" id="dataType"
                    name="dataType">
                <option value="sql">sql</option>
                <option value="json">json</option>
                <option value="sql-regex">sql-regex</option>
            </select>
            <div class="input-group-prepend">
                <span class="input-group-text">tinyint转换类型</span>
            </div>
            <select type="text" class="form-control" id="tinyintTransType"
                    name="tinyintTransType">
                <option value="boolean">boolean</option>
                <option value="Boolean">Boolean</option>
                <option value="Integer">Integer</option>
                <option value="int">int</option>
                <option value="String">String</option>
            </select>
            <div class="input-group-prepend">
                <span class="input-group-text">命名转换规则</span>
            </div>
            <select type="text" class="form-control" id="nameCaseType"
                    name="nameCaseType">
                <option value="CamelCase">驼峰</option>
                <option value="UnderScoreCase">下划线</option>
                <#--<option value="UpperUnderScoreCase">大写下划线</option>-->
            </select>
            <div class="input-group-prepend">
                <span class="input-group-text">swagger-ui</span>
            </div>
            <select type="text" class="form-control" id="isSwagger"
                    name="isSwagger">
                <option value="false">关闭</option>
                <option value="true">开启</option>
            </select>
        </div>
        <p><button class="btn btn-primary disabled" id="btnGenCode" role="button" data-toggle="popover" data-content="">开始生成 »</button> <button class="btn alert-secondary" id="btnCopy">一键复制</button></p>
        <div id="history" class="btn-group" role="group" aria-label="Basic example"></div>
        <hr>
        <!-- Example row of columns -->
        <div class="row" style="margin-top: 10px;">
            <div class="btn-toolbar col-md-5" role="toolbar" aria-label="Toolbar with button groups">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <div class="btn btn-secondary disabled setWidth" id="btnGroupAddon">通用实体</div>
                    </div>
                </div>
                <div class="btn-group" role="group" aria-label="First group">
                    <button type="button" class="btn btn-default generator" id="model">entity(set/get)</button>
                    <button type="button" class="btn btn-default generator" id="beetlentity">entity(lombok)</button>
                </div>
            </div>
            <div class="btn-toolbar col-md-7" role="toolbar" aria-label="Toolbar with button groups">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <div class="btn btn-secondary disabled setWidth" id="btnGroupAddon">Mybatis</div>
                    </div>
                </div>
                <div class="btn-group" role="group" aria-label="First group">
                    <button type="button" class="btn btn-default generator" id="mybatis">mybatis</button>
                    <button type="button" class="btn btn-default generator" id="mapper">mapper</button>
                    <button type="button" class="btn btn-default generator" id="service">service</button>
                    <button type="button" class="btn btn-default generator" id="service_impl">service_impl</button>
                    <button type="button" class="btn btn-default generator" id="controller">controller</button>
                </div>
            </div>
        </div>
        <!-- Example row of columns -->
        <div class="row" style="margin-top: 10px;">
            <div class="btn-toolbar col-md-5" role="toolbar" aria-label="Toolbar with button groups">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <div class="btn btn-secondary disabled setWidth" id="btnGroupAddon">MybatisPlus</div>
                    </div>
                </div>
                <div class="btn-group" role="group" aria-label="First group">
                    <button type="button" class="btn btn-default generator" id="plusentity">entity</button>
                    <button type="button" class="btn btn-default generator" id="plusmapper">mapper</button>
                    <button type="button" class="btn btn-default generator" id="pluscontroller">controller</button>
                </div>
            </div>

            <div class="btn-toolbar col-md-7" role="toolbar" aria-label="Toolbar with button groups">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <div class="btn btn-secondary disabled setWidth" id="btnGroupAddon">UI</div>
                    </div>
                </div>
                <div class="btn-group" role="group" aria-label="First group">
                    <button type="button" class="btn btn-default generator" id="swagger-ui">swagger-ui</button>
                    <button type="button" class="btn btn-default generator" id="element-ui">element-ui</button>
                    <button type="button" class="btn btn-default generator" id="bootstrap-ui">bootstrap-ui</button>
                    <button type="button" class="btn btn-default generator" id="layui-edit">layui-edit</button>
                    <button type="button" class="btn btn-default generator" id="layui-list">layui-list</button>
                </div>
            </div>
        </div>

        <div class="row" style="margin-top: 10px;">
            <div class="btn-toolbar col-md-5" role="toolbar" aria-label="Toolbar with button groups">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <div class="btn btn-secondary disabled setWidth" id="btnGroupAddon">BeetlSQL</div>
                    </div>
                </div>
                <div class="btn-group" role="group" aria-label="First group">
                    <button type="button" class="btn btn-default generator" id="beetlmd">beetlmd</button>
                    <button type="button" class="btn btn-default generator" id="beetlcontroller">beetlcontroller</button>
                </div>
            </div>
            <div class="btn-toolbar col-md-5" role="toolbar" aria-label="Toolbar with button groups">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <div class="btn btn-secondary disabled setWidth" id="btnGroupAddon">JPA</div>
                    </div>
                </div>
                <div class="btn-group" role="group" aria-label="First group">
                    <button type="button" class="btn btn-default generator" id="entity">jpa-entity</button>
                    <button type="button" class="btn btn-default generator" id="repository">repository</button>
                    <button type="button" class="btn btn-default generator" id="jpacontroller">controller</button>
                </div>
            </div>
        </div>
        <div class="row" style="margin-top: 10px;">
            <div class="btn-toolbar col-md-5" role="toolbar" aria-label="Toolbar with button groups">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <div class="btn btn-secondary disabled setWidth" id="btnGroupAddon">JdbcTemplate</div>
                    </div>
                </div>
                <div class="btn-group" role="group" aria-label="First group">
                    <button type="button" class="btn btn-default generator" id="jtdaoimpl">daoimpl</button>
                    <button type="button" class="btn btn-default generator" id="jtdao">dao</button>
                </div>
            </div>
            <div class="btn-toolbar col-md-7" role="toolbar" aria-label="Toolbar with button groups">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <div class="btn btn-secondary disabled setWidth" id="btnGroupAddon">SQL</div>
                    </div>
                </div>
                <div class="btn-group" role="group" aria-label="First group">
                    <button type="button" class="btn btn-default generator" id="select">select</button>
                    <button type="button" class="btn btn-default generator" id="insert">insert</button>
                    <button type="button" class="btn btn-default generator" id="update">update</button>
                    <button type="button" class="btn btn-default generator" id="delete">delete</button>
                </div>
            </div>
        </div>
        <div class="row" style="margin-top: 10px;">
            <div class="btn-toolbar col-md-5" role="toolbar" aria-label="Toolbar with button groups">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <div class="btn btn-secondary disabled setWidth" id="btnGroupAddon">Util</div>
                    </div>
                </div>
                <div class="btn-group" role="group" aria-label="First group">
                    <button type="button" class="btn btn-default generator" id="util">bean get set</button>
                    <button type="button" class="btn btn-default generator" id="json">json</button>
                    <button type="button" class="btn btn-default generator" id="xml">xml</button>
                </div>
            </div>
        </div>
        <hr>
        <textarea id="genCodeArea" class="form-control btn-lg" ></textarea>
    </div>
</div>

    <@netCommon.commonFooter />
</body>
</html>
