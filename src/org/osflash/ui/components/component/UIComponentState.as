package org.osflash.ui.components.component
{
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class UIComponentState implements IUIComponentState
	{
		
		/**
		 * @private
		 */
		private var _enabled : Boolean;
		
		/**
		 * @private
		 */
		private var _hovered : Boolean;
		
		/**
		 * @private
		 */
		private var _focused : Boolean;
		
		/**
		 * @private
		 */
		private var _pressed :  Boolean;
		
		/**
		 * @private
		 */
		private var _component : IUIComponent;
		
		/**
		 * @private
		 */
		private var _signalProxy : IUIComponentSignalProxy;
		
		public function UIComponentState()
		{
			_enabled = true;
			_hovered = false;
			_focused = false;
			_pressed = false;
		}
		
		/**
		 * @inheritDoc
		 */		
		public function bind(component : IUIComponent) : void
		{
			if(null == component) throw new ArgumentError('IUIComponent can not be null');
			
			_component = component;
			_signalProxy = _component.signalProxy;
			
			if(null == _signalProxy) throw new ArgumentError('IUIComponentSignalProxy can not ' + 
																						'be null'); 
		}

		/**
		 * @inheritDoc
		 */
		public function unbind() : void
		{
			_component = null;
			_signalProxy = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get enabled() : Boolean { return _enabled; }
		public function set enabled(value : Boolean) : void
		{
			if (_enabled != value)
			{
				_enabled = value;
				_signalProxy.enabled.dispatch(value);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get hovered() : Boolean { return _hovered; }
		public function set hovered(value : Boolean) : void
		{
			if (_hovered != value)
			{
				_hovered = value;
				_signalProxy.hovered.dispatch(value);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get focused() : Boolean { return _focused; }
		public function set focused(value : Boolean) : void
		{
			if (_focused != value)
			{
				_focused = value;
				_signalProxy.focused.dispatch(value);
			}
		}

		/**
		 * @inheritDoc
		 */
		public function get pressed() : Boolean { return _pressed; }
		public function set pressed(value : Boolean) : void
		{
			if(_pressed != value)
			{
				_pressed = value;
				_signalProxy.pressed.dispatch(value);
			}
		}
	}
}
