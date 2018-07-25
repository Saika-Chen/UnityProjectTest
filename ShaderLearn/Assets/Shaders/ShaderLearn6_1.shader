﻿Shader "Unity Shader Book/Chapter6/Diffuse Vertex-Level"
{
       Properties
       {
             _Diffuse("Diffuse",Color) = (1.0,1.0,1.0,1.0)
             _Specular("Specular",Color) = (1.0,1.0,1.0,1.0)
             _Gloss("Gloss",Range(8.0,256)) = 20 //size of specular area
       }
       SubShader
       {
             Tags { "LightMode"="ForwardBase" }  
  
             Pass
             {
                    CGPROGRAM
                    #pragma vertex vert
                    #pragma fragment frag
                     
                    #include "Lighting.cginc"
  
                    fixed4 _Diffuse;
                    fixed4 _Specular;
                    float  _Gloss;
                    struct appdata
                    {
                          float4 vertex : POSITION; //顶点在模型空间的坐标
                          float3 normal : NORMAL;  //法线
                    } ;
  
                    struct v2f
                    {
                          fixed3 color : COLOR;  //输出颜色
                          float4 pos : SV_POSITION;  //输出位置
                    } ;
  
                     
                    v2f vert (appdata v)
                    {
                          v2f o;
                          o.pos = UnityObjectToClipPos(v.vertex);  //模型空间转换到裁剪空间
  
                          fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;  //环境光
  
                          fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject)); //法线方向n
  
                          fixed3 worldLightDir   = normalize(_WorldSpaceLightPos0.xyz); //光源位置
						  fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir ));  //公式计算
                          //fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (saturate(dot(worldNormal,worldLight))*0.5+0.5);  //公式计算
						  o.color = ambient + diffuse;
  //高光反射
                        fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal)); //反射方向矢量r
  
                          fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v.vertex).xyz); //视线方向
  
                          fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss); //公式计算
                          o.color = ambient + diffuse+specular;
  
                          return o;
                    }
                     
                    fixed4 frag (v2f i) : SV_Target
                    {
                          return fixed4(i.color,1.0);
                    }
                    ENDCG
             }
       }
}

//// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
//// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


//Shader "Unity Shader Book/Chapter 6/Diffuse Vertex-Level"
//{
//  Properties
//  {
//    //用来控制材质的漫反射颜色
//    _Diffuse ("Diffuse", Color) = (1,1,1,1)
//  }
  
//  SubShader
//  {
//    Pass
//    {
//      //LightMode 标签是Pass标签的一种，它用于定义该Pass在Unity的光照流水线中的角色。
//      Tags {"LightMode" = "ForwardBase"}
      
//      CGPROGRAM
//      #pragma vertex vert
//      #pragma fragment frag
      
//      //为了使用Unity内置的一些变量而包含内置文件
//      #include "Lighting.cginc"
      
//      //为了在Shader中使用Properties语义块中声明的属性，我们需要定义一个和该属性类型相匹配的变量
//      //通过这样的方式，我们就可以得到漫反射公式中需要的参数之一——材质的漫反射属性。
//      //由于颜色属性的范围在0到1之间，因此我们可以使用fixed精度的变量来存储它。
//      fixed4 _Diffuse;
      
//      //顶点着色器的输入结构体
//      //为了访问顶点的法线，我们需要再a2v中定义一个normal变量，并通过使用NORMAL语义来告诉Unity
//      //要把模型顶点的法线信息存储到normal变量中。
//      struct a2v
//      {
//        float4 vertex : POSITION;
//        float3 normal : NORMAL;
//      };
      
//      //顶点着色器的输出结构体（同时也是片元着色器的输入结构体）
//      //为了把在顶点着色器中计算得到的光照颜色传递给片元，我们需要再v2f中定义一个color变量，且并不是必须使用COLOR语义
//      struct v2f
//      {
//        float4 pos : SV_POSITION;
//        fixed3 color : COLOR;
//      };
      
//      v2f vert(a2v v)
//      {
//        //定义返回值o
//        v2f o;
//        //顶点着色器最基本任务就是把顶点位置从模型空间转换到裁剪空间中，因此需要用矩阵来进行变换
//        o.pos = UnityObjectToClipPos(v.vertex);
//        //我们通过Unity的内置变量UNITY_LIGHTMODEL_AMBIENT 得到了环境光部分
//        fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        
//        //然后开始真正计算漫反射光照部分，首先我们已经知道了材质的漫反射颜色_Diffuse以及顶点法线v.normal。
//        //我们还需要知道光源的颜色和强度信息以及光源方向。Unity提供了我么一个内置变量_LightColor0来访问该Pass处理的光源的颜色和
//        //强度信息（注意，想要得到正确的值需要定义合适的LightMode标签），
//        //而光源方向可以由_WorldSpaceLightPos0 来得到。需要注意的是，这里对光源方向的计算并不具有通用性
        
//        //在计算法线和光源方向之间的点积时，我们需要选择它们所在的坐标系，只有两者处于同一坐标空间下，它们的点积才有意义。
//        //在这里，我们选择了世界坐标空间。而由a2v得到的顶点法线是处于模型空间下的，因此我们首先需要把法线转换到世界空间中。
//        //在第4章中，我们已经知道可以使用顶点变换矩阵的逆转置对法线进行相同的变换，因此我们首先得到模型空间到世界空间的
//        //变换矩阵的逆矩阵_World2Object，然后通过调换它在mul函数中的位置，得到和转置矩阵相同的矩阵乘法。
//        //由于法线是一个三维矢量，因此我们只需要截取_World2Object的前三行前三列即可。
//        fixed3 worldNormal = normalize(mul(v.normal, (float3×3)unity_WorldToObject));
        
//        fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
        
//        //在得到了世界空间中的法线和光源方向后，我们需要对它们进行归一化操作。在得到它们点击的结果后，我们使用saturate函数
//        //把参数截取到[0, 1]范围内。最后，再与光源颜色和强度以及材质的漫反射颜色相乘可得到最终的漫反射光照部分
//        fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));
        
//        //最后我们对环境光和漫反射部分相加，得到最终的光照结果
//        o.color = ambient + diffuse;
        
//        return o;
//      }
      
//      //由于所有的计算在顶点着色器中都已完成了，因此片元着色器的代码很简单，我们只需要直接把顶点颜色输出即可
//      fixed4 frag(v2f i) : SV_Target
//      {
//        return fixed4(i.color,1.0);
//      }
      
//      ENDCG
//    }
//  }
  
//  FallBack "Diffuse"
//}