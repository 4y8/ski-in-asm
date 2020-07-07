run:
	/* Save the callers's address */
	pop  %r8
	movq nadds, %r9
	movq %r8, adds(, %r9, 8)
	incq nadds
	pop  %rbx                   /* Get the root node */
	cmp  $0, %rbx               /* Check if it's an S node */
	je   snode
	cmp  $1, %rbx               /* Check if it's a K node */
	je   knode
	cmp  $2, %rbx               /* Check if it's a U node (successor) */
	je   unode
	cmp  $3, %rbx               /* Check if it's a Z node */
	je   znode
	cmp  $4, %rbx               /* Check if it's a I node */
	je   inode
	cmp  $5, %rbx               /* Check if it's a B node */
	je   bnode
	cmp  $6, %rbx               /* Check if it's a C node */
	je   cnode
	cmp  $7, %rbx               /* Check if it's a S' node */
	je   spnode
	cmp  $8, %rbx               /* Check if it's a B* node */
	je   bsnode
	cmp  $9, %rbx               /* Check if it's a C' node */
	je   cnode
	/* Otherwise it's an internal node and we push its two leaves */
	sub  $9, %rbx
	push nodes(, %rbx, 8)
	dec  %rbx
	push nodes(, %rbx, 8)
	call run
	jmp  end
snode:
    	/* Get the 3 arguments */
	pop  %rbx
	pop  %rcx
	pop  %rdx
	mov  nodelen(, 1), %rsi	    /* Create an internal node (y z) */
	add  $10, %rsi
	push %rsi
	sub  $10, %rsi
	mov  %rcx, nodes(, %rsi, 8)
	inc  %rsi
	mov  %rdx, nodes(, %rsi, 8)
	inc  %rsi
	mov  %rsi, nodelen(, 1)
	push %rdx                   /* Push z and x on the stack */
	push %rbx
	/* S x y z became x z (y z) on the stack */
	call run
	jmp end
knode:
	/* Get the 2 arguments */
	pop  %rbx                   /* x */
	pop  %rcx                   /* y */
	/* Push x on the stack */
	push %rbx
	/* K x y became x on the stack */
	call run
	jmp end
unode:
        /* Evaluate the rest of the stack and increment the result */
	call run
	inc  %rax
	jmp  end
znode:
	mov  $0, %rax               /* Evaluates to 0 */
	jmp  end
inode:
	/* I x -> x so we evaluate the rest of the stack */
	call run
	jmp end
bnode:
	/* Get the 3 arguments */
	pop  %rbx
	pop  %rcx
	pop  %rdx
	mov  nodelen, %rsi	    /* Create an internal node (y z) */
	add  $10, %rsi
	push %rsi
	sub  $10, %rsi
	mov  %rcx, nodes(, %rsi, 8)
	inc  %rsi
	mov  %rdx, nodes(, %rsi, 8)
	inc  %rsi
	mov  %rsi, nodelen
	push %rbx                   /* Push x on the stack */
	/* B x y z became x (y z) on the stack */
	call run
	jmp end
cnode:
	/* Get the 3 arguments */
	pop  %rbx
	pop  %rcx
	pop  %rdx
	/* Push the arguments an flip the third and the  second */
	push %rcx
	push %rdx
	push %rbx
	/* C x y z became x z y on the stack */
	call run
	jmp end
spnode:
	/* Get the 4 arguments */
	pop  %rdi                    /* c */
	pop  %rbx                    /* f */
	pop  %rcx                    /* g */
	pop  %rdx                    /* x */
	mov  nodelen, %rsi
	add  $12, %rsi
	push %rsi
	sub  $2, %rsi
	push %rsi
	sub  $10, %rsi
	mov  %rbx, nodes(, %rsi, 8) /* Creates an internal node (f x) */
	inc  %rsi
	mov  %rdx, nodes(, %rsi, 8)
	inc  %rsi
	mov  %rcx, nodes(, %rsi, 8) /* Creates an internal node (g x) */
	inc  %rsi
	mov  %rdx, nodes(, %rsi, 8)
	inc  %rsi
	mov  %rsi, nodelen
	push %rdi
	/* S' c f g x became c (f x) (g x) on the stack */
	call run
	jmp end
bsnode:
	/* Get the 4 arguments */
	pop  %rdi                    /* c */
	pop  %rbx                    /* f */
	pop  %rcx                    /* g */
	pop  %rdx                    /* x */
	mov  nodelen, %rsi
	/* Creates an internal node f (g x) */
	add  $10, %rsi
	push %rsi
	sub  $10, %rsi
	mov  %rbx, nodes(, %rsi, 8)
	inc  %rsi
	mov  %rsi, %r10
	add  $11, %r10
	mov  %r10, nodes(, %rsi, 8)
	inc  %rsi
	mov  %rcx, nodes(, %rsi, 8)
	inc  %rsi
	mov  %rdx, nodes(, %rsi, 8)
	inc  %rsi
	mov  %rsi, nodelen
	push %rdi
	/* B* c f g x became c (f (g x)) on the stack */
	call run
	jmp end
cpnode:
	/* Get the 4 arguments */
	pop  %rdi                    /* c */
	pop  %rbx                    /* f */
	pop  %rcx                    /* g */
	pop  %rdx                    /* x */
	mov  nodelen, %rsi
	push %rdx
	add  $10, %rsi
	push %rsi
	sub  $10, %rsi
	mov  %rbx, nodes(, %rsi, 8) /* Creates an internal node (f x) */
	inc  %rsi
	mov  %rdx, nodes(, %rsi, 8)
	inc  %rsi
	mov  %rsi, nodelen
	push %rdi
	/* C' c f g x became c (f x) g on the stack */
	call run
	jmp end
end:
	decq nadds
	movq nadds, %r8
	push adds(, %r8, 8)
	ret
