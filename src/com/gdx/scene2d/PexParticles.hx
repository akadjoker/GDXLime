package com.gdx.scene2d;
import com.gdx.color.Color4;
import lime.Assets;


/**
 * ...
 * @author djoekr
 */

 enum EmitterType
{
    Gravity; Radial;
}

class PexParticles
{

	 public var texture :Texture;

    public var maxParticles :Int;

    public var type :EmitterType;

    // public var emitX :Float;
    public var emitXVariance :Float;

    // public var emitY :Float;
    public var emitYVariance :Float;

    public var alphaStart :Float;
    public var alphaStartVariance :Float;

	public var rStart :Float;
    public var rStartVariance :Float;

    public var gStart :Float;
    public var gStartVariance :Float;
	
	public var bStart :Float;
    public var bStartVariance :Float;

	
	public var rEnd :Float;
    public var rEndVariance :Float;

	public var gEnd :Float;
    public var gEndVariance :Float;

	public var bEnd :Float;
    public var bEndVariance :Float;

    public var alphaEnd :Float;
    public var alphaEndVariance :Float;

    public var angle :Float;
    public var angleVariance :Float;

    public var duration :Float;

    public var gravityX :Float;
    public var gravityY :Float;

    public var maxRadius :Float;
    public var maxRadiusVariance :Float;

    public var minRadius :Float;

    public var lifespanVariance :Float;
    public var lifespan :Float;

    public var rotatePerSecond :Float;
    public var rotatePerSecondVariance :Float;

    public var rotationStart :Float;
    public var rotationStartVariance :Float;

    public var rotationEnd :Float;
    public var rotationEndVariance :Float;

    public var sizeStart :Float;
    public var sizeStartVariance :Float;

    public var sizeEnd :Float;
    public var sizeEndVariance :Float;

    public var speed :Float;
    public var speedVariance :Float;

    public var radialAccel :Float;
    public var radialAccelVariance :Float;

    public var tangentialAccel :Float;
    public var tangentialAccelVariance :Float;

	public var startColor:Color4 = new Color4();
	public var endColor:Color4 = new Color4();
	
	
    public var blendMode :Int;

    public function new ( name :String)
    {
        var blendFuncSource = 0;
        var blendFuncDestination = 0;
		

        var xml = Xml.parse(Assets.getText(name));
        for (element in xml.firstElement().elements()) {
            switch (element.nodeName.toLowerCase()) {
            case "texture":
		
				
				 texture=Gdx.Instance().getTexture("data/"+element.get("name"));
				 
               // texture = pack.getTexture(element.get("name").removeFileExtension());
            case "angle":
                angle = getValue(element);
            case "anglevariance":
                angleVariance = getValue(element);
            case "blendfuncdestination":
                blendFuncDestination = Std.int(getValue(element));
            case "blendfuncsource":
                blendFuncSource = Std.int(getValue(element));
            case "duration":
                duration = getValue(element);
            case "emittertype":
                type = (Std.int(getValue(element)) == 0) ? Gravity : Radial;
            case "finishcolor":
				rEnd = getFloat(element, "red");
				gEnd = getFloat(element, "green");
				bEnd = getFloat(element, "blue");
                alphaEnd = getFloat(element, "alpha");
            case "finishcolorvariance":
				rEndVariance = getFloat(element, "red");
				gEndVariance = getFloat(element, "green");
				bEndVariance = getFloat(element, "blue");
                alphaEndVariance = getFloat(element, "alpha");
            case "finishparticlesize":
                sizeEnd = getValue(element);
            case "finishparticlesizevariance":
                sizeEndVariance = getValue(element);
            case "gravity":
                gravityX = getX(element);
                gravityY = getY(element);
            case "maxparticles":
                maxParticles = Std.int(getValue(element));
            case "maxradius":
                maxRadius = getValue(element);
            case "maxradiusvariance":
                maxRadiusVariance = getValue(element);
            case "minradius":
                minRadius = getValue(element);
            case "particlelifespan":
                lifespan = getValue(element);
            case "particlelifespanvariance":
                lifespanVariance = getValue(element);
            case "radialaccelvariance":
                radialAccelVariance = getValue(element);
            case "radialacceleration":
                radialAccel = getValue(element);
            case "rotatepersecond":
                rotatePerSecond = getValue(element);
            case "rotatepersecondvariance":
                rotatePerSecondVariance = getValue(element);
            case "rotationend":
                rotationEnd = getValue(element);
            case "rotationendvariance":
                rotationEndVariance = getValue(element);
            case "rotationstart":
                rotationStart = getValue(element);
            case "rotationstartvariance":
                rotationStartVariance = getValue(element);
            // case "sourceposition":
            case "sourcepositionvariance":
                emitXVariance = getX(element);
                emitYVariance = getY(element);
            case "speed":
                speed = getValue(element);
            case "speedvariance":
                speedVariance = getValue(element);
            case "startcolor":
				rStart = getFloat(element, "red");
				gStart = getFloat(element, "green");
				bStart = getFloat(element, "blue");
                alphaStart = getFloat(element, "alpha");
            case "startcolorvariance":
				rStartVariance = getFloat(element, "red");
				gStartVariance = getFloat(element, "green");
				bStartVariance = getFloat(element, "blue");
                alphaStartVariance = getFloat(element, "alpha");
            case "startparticlesize":
                sizeStart = getValue(element);
            case "startparticlesizevariance":
                sizeStartVariance = getValue(element);
            case "tangentialaccelvariance":
                tangentialAccelVariance = getValue(element);
            case "tangentialacceleration":
                tangentialAccel = getValue(element);
            }
        }

         if (lifespan <= 0) {
            lifespan = duration;
        }
		
		blendMode = BlendMode.NORMAL;

        if (blendFuncSource == 1 && blendFuncDestination == 1)
		{
            blendMode = BlendMode.ADD;
			trace("blend add");
        } else if (blendFuncSource == 1 && blendFuncDestination == 771) 
		{
            blendMode = BlendMode.NORMAL; // Normal
			trace("blend normal");
        } else if (blendFuncSource != 0 || blendFuncDestination != 0) 
		{
        //    Log.warn("Unsupported particle blend functions", [
          //      "emitter", name, "source", blendFuncSource, "dest", blendFuncDestination ]);
        }
		
	//blendMode = BlendMode.ADD;
    }



    private  function getFloat (xml :Xml, name :String) :Float
    {
        return Std.parseFloat(xml.get(name));
    }

    inline private  function getValue (xml :Xml) :Float
    {
        return getFloat(xml, "value");
    }

    inline private  function getX (xml :Xml) :Float
    {
        return getFloat(xml, "x");
    }

    inline private  function getY (xml :Xml) :Float
    {
        return getFloat(xml, "y");
    }
	
}