//------------------------------------------------------------------------------
// <auto-generated>
//     此代码由工具生成。
//     运行时版本:4.0.30319.17929
//
//     对此文件的更改可能会导致不正确的行为，并且如果
//     重新生成代码，这些更改将会丢失。
// </auto-generated>
//------------------------------------------------------------------------------
using System;
using UnityEngine;

//物理资源
namespace BlGame.Resource
{
        
		public class PhyResouce
		{
            //
            public string resPath
            {
                get;
                set;
            }
            //
            public EPhyResType phyResType;
            //
            public enum EPhyResType
            {
                EPhyResLevel,               //场景,通常用于保存场景碰撞，光照信息，雾效等
                EPhyResPrefab,              //预设,通常是逻辑资源的入口
                EPhyResTexture,             //纹理
                EPhyResShader,              //shader
                EPhyResModel,               //模型
                EPhyResAnimationClip,       //动画
                EPhyResSound,               //声音
                EPhyText,                   //文本，xml等
            }
            //
			public PhyResouce ()
			{

			}
            //
            public PhyResouce(string path)
            {
                resPath = path;
            }
            //
            public AssetBundle assetBundle;


            public Texture2D getTexture()
            {
                return (Texture2D)assetBundle.mainAsset;
            }
		}
}

