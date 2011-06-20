package org.osflash.ui.components.themes.graphic.analog
{
	import flash.display.DisplayObject;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.natives.NativeSignal;
	import org.osflash.ui.components.analog.IUIAnalogStickView;
	import org.osflash.ui.components.analog.UIAnalogStick;
	import org.osflash.ui.components.analog.UIAnalogStickModel;
	import org.osflash.ui.components.analog.UIAnalogStickSignalProxy;
	import org.osflash.ui.components.button.UIButton;
	import org.osflash.ui.components.component.IUIComponent;
	import org.osflash.ui.components.component.UIComponentStateAction;
	import org.osflash.ui.components.themes.graphic.component.IUIComponentViewConfig;
	import org.osflash.ui.components.themes.graphic.component.UIGraphicComponentView;
	import org.osflash.ui.components.themes.graphic.component.UIGraphicsData;
	import org.osflash.ui.signals.ISignalTarget;

	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;

	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class UIAnalogStickView extends UIGraphicComponentView implements IUIAnalogStickView
	{
		
		public static const MATH_PI_TWO : Number = Math.PI * 2;
		
		/**
		 * @private
		 */
		private var _component : UIAnalogStick;
		
		/**
		 * @private
		 */
		private var _container :  DisplayObjectContainer;
		
		/**
		 * @private
		 */
		private var _model : UIAnalogStickModel;
		
		/**
		 * @private
		 */
		private var _signalProxy : UIAnalogStickSignalProxy;
		
		/**
		 * @private
		 */
		private var _background : Shape;
		
		/**
		 * @private
		 */
		private var _button : UIButton;
		
		/**
		 * @private
		 */
		private var _config : IUIAnalogStickViewConfig;
		
		/**
		 * @private
		 */
		private var _colourScheme : IUIAnalogStickColourScheme;
		
		/**
		 * @private
		 */
		private var _graphicsData : UIGraphicsData;
		
		/**
		 * @private
		 */
		private var _radius : int;
		
		/**
		 * @private
		 */
		private var _buttonTarget : Point;
		
		/**
		 * @private
		 */
		private var _buttonMouseDown : Boolean;
		
		/**
		 * @private
		 */
		private var _buttonMouseDownPos : Point;
		
		/**
		 * @private
		 */
		private var _animating : Boolean;
		
		/**
		 * @private
		 */
		private var _positionStoredValue : Boolean;
		
		/**
		 * @private
		 */
		private var _nativeEnterFrameSignal : ISignal;
				
		public function UIAnalogStickView(config : IUIAnalogStickViewConfig)
		{
			super();
			
			_config = config;
		}
		
		/**
		 * @inheritDoc
		 */	
		override public function bind(component : IUIComponent) : void
		{
			super.bind(component);
						
			_component = UIAnalogStick(component);
			
			_container = _component.displayObjectContainer;
			_container.addChild(_background = new Shape());
			_component.add(_button = new UIButton(_config.buttonView));

			_model = UIAnalogStickModel(_component.model);

			_signalProxy = UIAnalogStickSignalProxy(_component.signalProxy);
			_signalProxy.action.add(handleActionSignal);
			_signalProxy.angle.add(handleAngleSignal);
			_signalProxy.radius.add(handleRadiusSignal);
			
			initConfig(_config);
			
			_animating = false;
			_positionStoredValue = false;
			
			_buttonTarget = new Point();
			_buttonMouseDown = false;
			_buttonMouseDownPos = new Point();
			
			_nativeEnterFrameSignal = new NativeSignal(_container, Event.ENTER_FRAME);
			
			_button.signals.mouseInSignal.add(handleButtonMouseInSignal);
			_button.signals.mouseDownSignal.add(handleButtonMouseDownSignal);
			_button.signals.mouseUpSignal.add(handleButtonMouseUpSignal);
			_button.signals.focusOutSignal.add(handleButtonFocusOutSignal);
		}
				
		/**
		 * @inheritDoc
		 */	
		override public function unbind() : void
		{
			_component = null;
			_container = null;
			
			if(null != _background)
			{
				if(null != _background.parent)
					_background.parent.removeChild(_background);
				_background = null;
			}
			
			if(null != _button)
			{
				_button.signals.mouseInSignal.remove(handleButtonMouseInSignal);
				_button.signals.mouseDownSignal.remove(handleButtonMouseDownSignal);
				_button.signals.mouseUpSignal.remove(handleButtonMouseUpSignal);
				_button.signals.focusOutSignal.remove(handleButtonFocusOutSignal);
				
				if(_component.contains(_button))
					_component.remove(_button);
				_button = null;
			}
			
			if(null != _signalProxy)
			{
				_signalProxy.action.remove(handleActionSignal);
				_signalProxy.angle.remove(handleAngleSignal);
				_signalProxy.radius.remove(handleRadiusSignal);
				_signalProxy = null;
			}
			
			super.unbind();
		}
		
		/**
		 * @inheritDoc
		 */	
		override public function captureTarget(point : Point) : ISignalTarget
		{
			if(!_container.visible || !_component.enabled) return null;
			if(_button.captureTarget(point)) return _button;
			
			const local : Point = _container.globalToLocal(point);
			const dx : Number = local.x - _radius;
			const dy : Number = local.y - _radius;
			
			const distance : Number = Math.sqrt((dx * dx) + (dy * dy));
			return (distance <= _radius) ? _component : null;
		}
		
		/**
		 * @inheritDoc
		 */	
		override public function resizeTo(width : int, height : int) : void
		{
			super.resizeTo(width, height);
			
			_radius = width * 0.5;
			
			_button.width = width * 0.5;
			_button.height = height * 0.5;
			
			const radius : int = _button.width * 0.5;
			
			_button.x = (_radius - radius);
			_button.y = (_radius - radius);
			
			repaint();
		}
		
		/**
		 * @private
		 */	
		override protected function initConfig(config : IUIComponentViewConfig) : void
		{
			super.initConfig(config);
			
			_colourScheme = _config.colourScheme;
			
			_graphicsData = _colourScheme.backgroundUp;
		}
		
		/**
		 * @private
		 */
		protected function repaint() : void
		{
			graphics.context(_background.graphics);
			
			graphics.clear();
			graphics.style(_graphicsData);
			graphics.drawCircle(innerBounds.x + _radius, innerBounds.y + _radius, _radius);
			graphics.endFill();
		}
		
		/**
		 * @private
		 */
		protected function updateButton() : void
		{
			if(_buttonMouseDown) return;
			
			if(_animating) _positionStoredValue = true;
			else
			{
				const radius : int = _button.width * 0.5;
				const offset : Number = _radius - radius;
				
				// Limit the distance			
				const r : Number = _model.radius * radius;
				
				const angle : Number = (_model.angle * MATH_PI_TWO) - Math.PI;
					
				// Put it back (cartesian)
				_button.x = (Math.cos(angle) * r) + offset;
				_button.y = (Math.sin(angle) * r) + offset;
				
				// TODO: Use Easing equation to move it back to the center.
				
				_positionStoredValue = false;
			}
		}
		
		/**
		 * @private
		 */
		protected function handleActionSignal(value : int) : void
		{
			if((value & UIComponentStateAction.PRESSED) != 0)
				_graphicsData = _colourScheme.backgroundDown;
			else 
			{
				if((value & UIComponentStateAction.HOVERED) != 0)
					_graphicsData = _colourScheme.backgroundOver;
				else
					_graphicsData = _colourScheme.backgroundUp;
			}
						
			repaint();
		}
				
		/**
		 * @private
		 */
		protected function handleAngleSignal(value : Number) : void
		{
			updateButton();
			
			value;
		}
		
		/**
		 * @private
		 */
		protected function handleRadiusSignal(value : Number) : void
		{
			updateButton();
			
			value;
		}
		
		/**
		 * @private
		 */
		protected function handleButtonMouseDownSignal(	target : ISignalTarget, 
														mousePos : Point
														) : void
		{
			if(target != _button) return;
						
			_buttonMouseDown = true;
			
			const radius : int = _button.width * 0.5;
			const offset : Number = _radius - radius;
			
			_buttonMouseDownPos = _button.displayObject.globalToLocal(mousePos);
			_buttonMouseDownPos.x -= offset;
			_buttonMouseDownPos.y -= offset;
						
			_nativeEnterFrameSignal.add(handleEnterFrameSignal);
		}
		
		/**
		 * @private
		 */
		protected function handleEnterFrameSignal(event : Event) : void
		{
			const radius : int = _button.width * 0.5;
			const offset : Number = _radius - radius;
			
			_animating = true;
			
			const displayObject : DisplayObject = _button.displayObject;
			
			if(_buttonMouseDown)
			{
				// Work out the distance
				const o : Number = offset * 2;
				const dx : Number = (_container.mouseX - _buttonMouseDownPos.x) - o;
				const dy : Number = (_container.mouseY - _buttonMouseDownPos.y) - o;
				const distance : Number = Math.sqrt((dx * dx) + (dy * dy));
				
				// Limit the distance			
				const r : Number = distance <= radius ? distance : radius;
				
				// Work out the rotation (polar)
				const angle : Number = Math.atan2(dy, dx);
				
				// Put it back (cartesian)
				_buttonTarget.x = (Math.cos(angle) * r) + offset;
				_buttonTarget.y = (Math.sin(angle) * r) + offset;
				
				displayObject.x += (_buttonTarget.x - displayObject.x) * 0.5;
				displayObject.y += (_buttonTarget.y - displayObject.y) * 0.5;
				
				// set the model
				_model.angle = (angle + Math.PI) / MATH_PI_TWO;
				_model.radius = r / radius;
			}
			else
			{
				// TODO : Turn this into an transition
				displayObject.x += (offset - displayObject.x) * 0.5;
				displayObject.y += (offset - displayObject.y) * 0.5;
				
				const x : Number = (displayObject.x - offset);
				const y : Number = (displayObject.y - offset);
				const absx : Number = x < 0 ? -x : x;
				const absy : Number = y < 0 ? -x : y;
				
				if(absx <= 0.2 && absy <= 0.2)
				{
					displayObject.x = offset;
					displayObject.y = offset;
					
					_animating = false;
					_nativeEnterFrameSignal.remove(handleEnterFrameSignal);
					
					if(_positionStoredValue) updateButton();					
				}
			}
		}
		
		/**
		 * @private
		 */
		protected function handleButtonMouseUpSignal(		target : ISignalTarget, 
															mousePos : Point
															) : void
		{
			_buttonMouseDown = false;
			
			target;
			mousePos;
		}
		
		/**
		 * @private
		 */
		protected function handleButtonMouseInSignal(		target : ISignalTarget, 
															mousePos : Point,
															mouseDown : Boolean
															) : void
		{
			if(!_component.state.hovered) _component.state.hovered = true;
			
			target;
			mousePos;
			mouseDown;
		}
		
		/**
		 * @private
		 */
		protected function handleButtonFocusOutSignal(target : ISignalTarget) : void
		{
			if(_component.state.hovered) _component.state.hovered = false;
			
			target;
		}
	}
}