import { Directive, HostListener } from '@angular/core';

@Directive({
  selector: '[scrollBlock]'
})
export class ScrollBlockDirective {

  constructor() {}

  @HostListener("wheel", ["$event"])
  public onScroll(event: WheelEvent) {
    event.preventDefault();
  }
}
