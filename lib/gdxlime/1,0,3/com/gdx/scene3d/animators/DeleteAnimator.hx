package com.gdx.scene3d.animators;

/**
 * ...
 * @author Luis Santos AKA DJOKER
 */
class DeleteAnimator extends Animator
{
    private var DeleteTime:Int;
	private var startTime:Int;
	public function new(time:Int) 
	{
		super();
		DeleteTime = time;
		startTime = Gdx.Instance().getTimer();
	}
	override public function animate(node:SceneNode):Void
	{
		if (Gdx.Instance().getTimer() >= startTime+DeleteTime)
		{
			
			node.Visible = false;
			node.Active = false;
			node.scene.addToDeletion(node);
		}
	}

	
}