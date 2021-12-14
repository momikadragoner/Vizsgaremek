import { Directive, ElementRef, HostListener, Input } from '@angular/core';

@Directive({
  selector: '[appHorizontalScroll]'
})
export class HorizontalScrollDirective {
  
  constructor(private element: ElementRef) {}

  @Input() appHorizontalScroll = false;

  @HostListener("wheel", ["$event"])
  public onScroll(event: WheelEvent) {
    if (this.appHorizontalScroll) {
      event.preventDefault();
      this.element.nativeElement.scrollLeft += event.deltaY;
    }
  }

}
