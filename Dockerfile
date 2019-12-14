ARG ALPINE_TAG=3.10
ARG MONO_VER=5.20.1.19-r1

FROM loxoo/alpine:${ALPINE_TAG} AS builder

ARG MONO_VER

### install mono-runtime
WORKDIR /output
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing mono=${MONO_VER}; \
    cp -a --parents /usr/lib/mono/4.5/gacutil.exe .; \
    for asm in \
        Accessibility \
        Commons.Xml.Relaxng \
        cscompmgd \
        CustomMarshalers \
        I18N.CJK \
        I18N \
        I18N.MidEast \
        I18N.Other \
        I18N.Rare \
        I18N.West \
        IBM.Data.DB2 \
        ICSharpCode.SharpZipLib \
        Microsoft.CSharp \
        Microsoft.VisualC \
        Microsoft.Web.Infrastructure \
        Mono.Btls.Interface \
        Mono.Cairo \
        Mono.CodeContracts \
        Mono.CompilerServices.SymbolWriter \
        Mono.CSharp \
        Mono.Data.Sqlite \
        Mono.Data.Tds \
        Mono.Debugger.Soft \
        Mono.Http \
        Mono.Management \
        Mono.Messaging \
        Mono.Messaging.RabbitMQ \
        Mono.Parallel \
        Mono.Posix \
        Mono.Profiler.Log \
        Mono.Security \
        Mono.Simd \
        Mono.Tasklets \
        Mono.WebBrowser \
        Novell.Directory.Ldap \
        nunit-console-runner \
        nunit.core \
        nunit.core.extensions \
        nunit.core.interfaces \
        nunit.framework \
        nunit.framework.extensions \
        nunit.mocks \
        nunit.util \
        PEAPI \
        RabbitMQ.Client \
        SMDiagnostics \
        System.ComponentModel.Composition \
        System.ComponentModel.DataAnnotations \
        System.Configuration \
        System.Configuration.Install \
        System.Core \
        System.Data.DataSetExtensions \
        System.Data \
        System.Data.Entity \
        System.Data.Linq \
        System.Data.OracleClient \
        System.Data.Services.Client \
        System.Data.Services \
        System.Deployment \
        System.Design \
        System.DirectoryServices \
        System.DirectoryServices.Protocols \
        System \
        System.Drawing.Design \
        System.Drawing \
        System.Dynamic \
        System.EnterpriseServices \
        System.IdentityModel \
        System.IdentityModel.Selectors \
        System.IO.Compression \
        System.IO.Compression.FileSystem \
        System.Json \
        System.Json.Microsoft \
        System.Management \
        System.Messaging \
        System.Net \
        System.Net.Http \
        System.Net.Http.Formatting \
        System.Net.Http.WebRequest \
        System.Numerics \
        System.Numerics.Vectors \
        System.Reactive.Core \
        System.Reactive.Debugger \
        System.Reactive.Experimental \
        System.Reactive.Interfaces \
        System.Reactive.Linq \
        System.Reactive.Observable.Aliases \
        System.Reactive.PlatformServices \
        System.Reactive.Providers \
        System.Reactive.Runtime.Remoting \
        System.Reactive.Windows.Forms \
        System.Reactive.Windows.Threading \
        System.Reflection.Context \
        System.Runtime.Caching \
        System.Runtime.DurableInstancing \
        System.Runtime.Remoting \
        System.Runtime.Serialization \
        System.Runtime.Serialization.Formatters.Soap \
        System.Security \
        System.ServiceModel.Activation \
        System.ServiceModel.Discovery \
        System.ServiceModel \
        System.ServiceModel.Internals \
        System.ServiceModel.Routing \
        System.ServiceModel.Web \
        System.ServiceProcess \
        System.Threading.Tasks.Dataflow \
        System.Transactions \
        System.Web.Abstractions \
        System.Web.ApplicationServices \
        System.Web \
        System.Web.DynamicData \
        System.Web.Extensions.Design \
        System.Web.Extensions \
        System.Web.Http \
        System.Web.Http.SelfHost \
        System.Web.Http.WebHost \
        System.Web.Mobile \
        System.Web.Mvc \
        System.Web.Razor \
        System.Web.RegularExpressions \
        System.Web.Routing \
        System.Web.Services \
        System.Web.WebPages.Deployment \
        System.Web.WebPages \
        System.Web.WebPages.Razor \
        System.Windows \
        System.Windows.Forms.DataVisualization \
        System.Windows.Forms \
        System.Workflow.Activities \
        System.Workflow.ComponentModel \
        System.Workflow.Runtime \
        System.Xaml \
        System.Xml \
        System.Xml.Linq \
        System.Xml.Serialization \
        WebMatrix.Data \
        WindowsBase; \
    do \
        cp -a --parents /usr/lib/mono/4.5/${asm}.dll .; \
        cp -a --parents /usr/lib/mono/gac/${asm} .; \
    done; \
    cp -a --parents /usr/bin/cert-sync .; \
    cp -a --parents /usr/lib/mono/4.5/cert-sync.exe .; \
    cp -a --parents /usr/lib/mono/4.5/mscorlib.dll  .; \
    cp -a --parents /etc/mono/config /etc/mono/mconfig /etc/mono/browscap.ini /etc/mono/2.0 /etc/mono/4.0 /etc/mono/4.5 .; \
    cp -a --parents /usr/bin/mono /usr/bin/mono-sgen .; \
    cp -a --parents /usr/lib/libMonoPosixHelper.so /usr/lib/libmono-btls-shared.so .; \
    cp -a --parents /usr/share/mono-2.0/mono/cil .

#=============================================================

FROM loxoo/alpine:${ALPINE_TAG}

ARG MONO_VER

LABEL org.label-schema.name="mono-runtime" \
      org.label-schema.description="A bare minimum Mono runtime docker image, based on Alpine" \
      org.label-schema.url="https://www.mono-project.com" \
      org.label-schema.version=${MONO_VER}

COPY --from=builder /output/ /

RUN apk add --no-cache libgcc sqlite-libs; \
    apk add --no-cache ca-certificates; \
    cert-sync /etc/ssl/certs/ca-certificates.crt; \
    apk del --no-cache ca-certificates
