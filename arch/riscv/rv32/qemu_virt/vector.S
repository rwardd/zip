.balign 128, 0
.option norvc
.global zvt
zvt:
irq0:
     j rv32_exception_handler
irq1:
     j rv32_isr
irq2:
     j rv32_isr
irq3:
     j rv32_isr
irq4:
     j rv32_isr
irq5:
     j rv32_isr
irq6:
     j rv32_isr
irq7:
     j rv32_isr
irq8:
     j rv32_isr
irq9:
     j rv32_isr
irq10:
     j rv32_isr
irq11:
     j rv32_isr
irq12:
     j rv32_isr
irq13:
     j rv32_isr
irq14:
     j rv32_isr
irq15:
     j rv32_isr
